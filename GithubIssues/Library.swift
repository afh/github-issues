//
//  ViewController.swift
//  FunctionalViewControllers
//
//  Created by Chris Eidhof on 03/09/14.
//  Copyright (c) 2014 Chris Eidhof. All rights reserved.
//

import UIKit

public class Box<T> {
    public let unbox: T
    public init(_ value: T) { self.unbox = value }
}

func map<A,B>(vc: Screen<A>, f: A -> B) -> Screen<B> {
    return Screen { callback in
        return vc.create { y in
            callback(f(y))
        }
    }
}


func map<A,B>(nc: NavigationController<A>, f: A -> B) -> NavigationController<B> {
    return NavigationController { callback in
        return nc.run { (y, nc) in
            callback(f(y), nc)
        }
    }
}

//func mapAsync<A,B,C>(vc: NavigationController<A,B>, f: (B, C -> ()) -> ()) -> NavigationController<A,C> {
//    return NavigationController { x, callback in
//        return vc.create(x) { (y, nc) in
//            f(y, { c in
//                callback(c, nc)
//            })
//        }
//    }
//}

struct Screen<A> {
    let create: (A -> ()) -> UIViewController
    
    init(_ create: (A -> ()) -> UIViewController) {
        self.create = create
    }
}

struct NavigationController<A> {
    let run: ((A, UINavigationController) -> ()) -> UINavigationController
}

func rootViewController<A>(vc: Screen<A>) -> NavigationController<A> {
    return NavigationController { callback in
        let navController = UINavigationController()
        let rootController = vc.create { callback($0, navController) }
        navController.viewControllers = [rootController]
        return navController
    }
}

infix operator >>> { associativity left }

func >>><A,B>(l: NavigationController<A>, r: A -> Screen<B>) -> NavigationController<B> {
    return NavigationController(run: { (callback) -> UINavigationController in
        let nc = l.run { a, nc in
            let rvc = r(a).create { c in
                callback(c, nc)
            }
            nc.pushViewController(rvc, animated: true)

        }
        return nc
    })
}

func textViewController(string: String) -> Screen<()> {
    return Screen { _ in
        var tv = TextViewController()
        tv.textView.text = string
        return tv
    }
}

class TextViewController: UIViewController {
    var textView: UITextView = {
        var tv = UITextView()
        tv.editable = false
        return tv
    }()
    
    override func viewDidLoad() {
        view.addSubview(textView)
        textView.frame = view.bounds
    }
}
