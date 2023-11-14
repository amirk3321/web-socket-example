//
//  ContentView.swift
//  WebSocketExample
//
//  Created by MA on 13/11/2023.
//

import SwiftUI


class WebSocketExampleViewModel : NSObject, ObservableObject , URLSessionWebSocketDelegate{
    
    
    
    
    @Published var message = ""
    @Published var errorMessage = ""
    
    private var webSokcet : URLSessionWebSocketTask?
    
    override init() {
        
        super.init()
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        
        
        guard let url = URL(string: "wss://URL") else {
            return
        }
        
        
        webSokcet = session.webSocketTask(with: url)
        webSokcet?.resume()
        
    }
    
    
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        ping()
        received()
        send()
        print("WebSocket Connection Open")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket Connection close")
    }
    
    func close()  {
        
        
        webSokcet?.cancel(with: .internalServerError, reason: "Demo WebSocket".data(using: .utf8))
        
    }
    
    func ping() {
        
        webSokcet?.sendPing {
            err in
            
            if let err = err {
                print("WebSocket Ping Erro \(err)")
            }
            
        }
        
    }
    
    func received()  {
        
        webSokcet?.receive(completionHandler: { [weak self] result in
            
            
            switch(result){
                
            case .success(let message) :
                switch (message) {
                    
                case .data(let data):
                    print("websocket Data: \(data)")
                case .string(let messsage):
                    
                    DispatchQueue.main.async {
                        print("Websocket message : \(messsage)")
                        
                        self?.message = "Websocket message : \(messsage)"
                        
                    }
                    
                
                    
                @unknown default:
                    break
                }
             
            case .failure(let err) :
                print("recevied err : \(err)")
                DispatchQueue.main.async {
                    
                    
                    self?.errorMessage = "Websocket message : \(err)"
                    
                }
                
                
            }
            
            self?.received()
            
            
        })
        
        
        
    }
    
    func send() {
        
        
        DispatchQueue.global().asyncAfter(deadline: .now()+5) {
            
            //self.send()
            print("Message Send bro in one sec continuesly")
           
            self.webSokcet?.send(.string("Send New Message \(Int.random(in: 1...1000))"), completionHandler: { err in
                
                
                if let err = err {
                    print("Web socket Message Send Error \(err)")
                }
                
            })
        }
        
    }
    
    
    
    
}



struct ContentView: View {
    
    
    @ObservedObject var vm  = WebSocketExampleViewModel()
    
    
    var body: some View {
        VStack {
            
            Button(action: {
                vm.close()
            }, label: {
                Text("Close Socket")
            }).padding()
            
            Text(vm.errorMessage )
            Text(vm.message)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
