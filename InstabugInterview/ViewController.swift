//
//  ViewController.swift
//  InstabugInterview
//
//  Created by Yousef Hamza on 1/13/21.
//

import UIKit
import InstabugNetworkClient

class ViewController: UIViewController {
    
    let color: [UIColor] = [.red, .blue, .black, .gray]
    var routesrs = [Router.getRequest, Router.responseHeaders, Router.postRequest(200)]
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func changeColor(_ sender: UIButton) {
        self.view.backgroundColor = color.randomElement()
        print("color changed ....")
        guard let router = routesrs.randomElement() else {return}
        NetworkClient.instance.request(with: router) { result in
            switch result {
            case .result(_, let response):
                print(response!.statusCode)
                sender.setTitle("\(response?.statusCode ?? 0)", for: .normal)
            case .error(let error, _):
                print(error!.localizedDescription)
            }
        }
        
    }
    
    
}

