//
//  ContentView.swift
//  carthage_compiled
//
//  Created by Benjamin Tang on 14/09/2022.
//

import SwiftUI
import PusherSwift

class MessageModel: ObservableObject, PusherDelegate {
    let pusher: Pusher
    @Published var message = "Received Pusher message will show here"
    
    func debugLog(message: String) {
        print(message)
    }

    func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
        print("State changed from \(old.stringValue()) to \(new.stringValue())")
    }
    
    func failedToSubscribeToChannel(name: String, response: URLResponse?, data: String?, error: NSError?) {
        print("Failed to subscribe to Channel \(name) \(response) \(data) \(error)")
    }
    
    init() {
        
        class AuthRequestBuilder: AuthRequestBuilderProtocol {
            func requestFor(socketID: String, channelName: String) -> URLRequest? {
                var request = URLRequest(url: URL(string: "https://dc33d18f6c07.ngrok.io/presence_auth")!)
                request.httpMethod = "POST"
                request.httpBody = "socket_id=\(socketID)&channel_name=\(channelName)".data(using: String.Encoding.utf8)
                request.addValue("myToken", forHTTPHeaderField: "Authorization")
                return request
            }
        }

        let options = PusherClientOptions(
             authMethod: .endpoint(authEndpoint: "https://1c39cd5af386.ngrok.io/auth"),
            // uncomment this if you want to use the default authrequestBuilder
            // authMethod: AuthMethod.authRequestBuilder(authRequestBuilder: AuthRequestBuilder()),
            host: .cluster("eu")
        )
        
        pusher = Pusher(key: "dc9b99559f2f8f0b22ce", options: options)

        pusher.connect()
        // logging part
        pusher.connection.delegate = self
        let publicChannel = pusher.subscribe("my-channel")
        //let privateChannel = pusher.subscribe("private-encrypted-channel")
        // let presenceChannel = pusher.subscribeToPresenceChannel(channelName: "presence-my-channel")
        
        publicChannel.bind(eventName: "pusher:subscription_succeeded", eventCallback: { _ in
            print("my-channel subscribed!")
        })
        publicChannel.bind(eventName: "my-event", eventCallback: { (event: PusherEvent) -> Void in
            if let data: String = event.data {
                self.message = data
            }
        })
        /*
        privateChannel.bind(eventName: "pusher:subscription_succeeded", eventCallback: { _ in
            print("private channel subscribed!")
        })
        privateChannel.bind(eventName: "my-event", eventCallback: { (event: PusherEvent) -> Void in
            if let data: String = event.data {
                self.message = data
            }
        })
         */
        /*
        presenceChannel.bind(eventName: "my-event", eventCallback: { (event: PusherEvent) -> Void in
            if let data: String = event.data {
                self.message = data
            }
        })
         */
    }
}

struct ContentView: View {
    @ObservedObject private var data = MessageModel()

    var body: some View {
        VStack {
            Text(data.message)
                .padding()
        }
        Button("Disconnect") {
            data.pusher.disconnect()
        }.padding()
        Button("Connect") {
            data.pusher.connect()
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
