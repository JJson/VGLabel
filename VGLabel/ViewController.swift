//
//  ViewController.swift
//  VGLabel
//
//  Created by Vein on 2017/11/7.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let text = "<font color='#7f7f7f' size=12>测试测试测试</font><font color='#2092db' size=12><a href='https://www.google.com/'>Goole</a></font><font color='#7f7f7f' size=12>，测试一下VGLabel，参考自RTLabel。</font>"
        let label = VGLabel()
        label.text = text
        label.delegate = self
        label.paragraphReplacement = ""
        print(label.optimumSize ?? "xxxx")
        label.frame = CGRect(origin: CGPoint(x: 0, y: 100), size: label.optimumSize!)
        view.addSubview(label)
    }
}

extension ViewController: VGLabelDelegate {
    func vgLabel(_ label: VGLabel, didSelectLink url: URL?) {
        print(url ?? "无URL")
    }
}
