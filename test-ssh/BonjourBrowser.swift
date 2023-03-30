//
//  BonjourBrowser.swift
//  test-ssh
//
//  Created by Huy Trinh Duc on 26/03/2023.
//

import Foundation
import Network
import NMSSH
import Socket
import NIO
import NIOEmbedded
import NIOCore
import NIOWebSocket
import NIOHTTP1

class BonjourScanner: NSObject, NetServiceBrowserDelegate {
    
    var smbServices = [NetService]()
    var sftpServices = [NetService]()
    var smbBrowser: NetServiceBrowser!
    var sftpBrowser: NetServiceBrowser!
    
    func startScanning() {
        smbBrowser = NetServiceBrowser()
        sftpBrowser = NetServiceBrowser()
        sftpBrowser.delegate = self
        sftpBrowser.searchForServices(ofType: "_ssh._tcp.", inDomain: "local.")
        smbBrowser.delegate = self
        smbBrowser.searchForServices(ofType: "_smb._tcp.", inDomain: "local.")
    }
    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print(service.type)
        if service.type == "_smb._tcp." {
            if let addresses = service.addresses {
                for address in addresses {
                    let ipAddress = String(describing: address).components(separatedBy: " ").last ?? ""
                    if !ipAddress.isEmpty {
                        print("Found SMB service: \(service.name) at IP address: \(ipAddress)")
                        smbServices.append(service)
                        break
                    }
                }
            }
        } else if service.type == "_ssh._tcp." {
            sftpServices.append(service)
            print("Found SFTP service: \(service.name)")
        }
        if !moreComing {
            print("Finished scanning for devices")
            // Do something with the found devices, such as display in a table view
        }
        print(smbServices.count, sftpServices.count)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("Error searching for services: \(errorDict)")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if let index = smbServices.firstIndex(where: { $0 === service }) {
            smbServices.remove(at: index)
            print("Removed SMB service: \(service.name)")
        } else if let index = sftpServices.firstIndex(where: { $0 === service }) {
            sftpServices.remove(at: index)
            print("Removed SFTP service: \(service.name)")
        }
    }
    
    func openSSH() {
        //        let devicesNameToHost = "\(devices[0].name.replacingOccurrences(of: "’", with: "").components(separatedBy: .whitespaces).joined(separator: "-")).\(devices[0].domain)"
        //
        //        let session = NMSSHSession(host: devicesNameToHost, andUsername: "huyparody")
        //        session.connect()
        //        if session.isConnected {
        //            session.authenticate(byPassword: "/")
        //            if session.isAuthorized {
        //                // Successfully connected and authenticated
        //                print("connect success")
        //
        //                let sftp = NMSFTP.connect(with: session)
        //                let directoryPath = "/"
        //                let directoryContents = sftp.contentsOfDirectory(atPath: directoryPath)?.forEach({print($0.filename)})
        //            }
        //            else {
        //                print("connect failed")
        //            }
        //        }
        
    }
    
}

class SSDPServer {
    
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let bootstrap: ServerBootstrap
    let channel: Channel
    
    init() throws {
        bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
//            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_IP), IP_MULTICAST_LOOP), value: 0)
            .serverChannelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_IP), IP_MULTICAST_TTL), value: 2)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
//            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_IP), IP_MULTICAST_LOOP), value: 0)
            .childChannelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_IP), IP_MULTICAST_TTL), value: 2)
            .childChannelInitializer { channel in
                let handler = SSDPHandler()
                return channel.pipeline.addHandlers([handler])
            }
        
        channel = try bootstrap.bind(host: "0.0.0.0", port: 1900).wait()
        
        do {
            try channel.eventLoop.scheduleRepeatedTask(initialDelay: .seconds(0), delay: .seconds(60)) { _ in
                let message = "NOTIFY * HTTP/1.1\r\nHost: 239.255.255.250:1900\r\nCache-Control: max-age=60\r\nLocation: http://127.0.0.1:8000\r\nServer: MySSDP\r\nNT: upnp:rootdevice\r\nNTS: ssdp:alive\r\nUSN: uuid:f40c2981-7329-40b7-8b04-27f187aecfb5::upnp:rootdevice\r\n\r\n"
                let data = message.data(using: .utf8)!
                let buffer = ByteBuffer(bytes: data)
                self.channel.writeAndFlush(buffer, promise: nil)
            }
        }
        catch {
            
        }
    }
    
    func run() throws {
        try channel.closeFuture.wait()
    }
    
    deinit {
        try? group.syncShutdownGracefully()
    }
}

class SSDPHandler: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let buffer = self.unwrapInboundIn(data)
        print("Received data: \(buffer)")
        context.fireChannelRead(data)
    }
}
