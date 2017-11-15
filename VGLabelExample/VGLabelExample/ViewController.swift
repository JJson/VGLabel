//
//  ViewController.swift
//  VGLabelExample
//
//  Created by Vein on 2017/11/15.
//  Copyright © 2017年 Vein. All rights reserved.
//

import UIKit
import VGLabel

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeightLayoutConstraint: NSLayoutConstraint!
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textTest()
        let label = VGLabel(frame: containerView.bounds)
        label.text = text
        label.delegate = self
        label.paragraphReplacement = ""
        containerView.addSubview(label)
        label.frame = CGRect(origin: containerView.bounds.origin, size: label.optimumSize!)
        containerViewHeightLayoutConstraint.constant = label.optimumSize!.height
    }
    
    func textTest() {
        text = "<font color='#2092db' size=23><a href='https://github.com/VeinGuo'>GitHub</a></font><font color='#7f7f7f' size=23>，测试一下VGLabel，参考自RTLabel。</font>"
        text += "<br><font face='HelveticaNeue-CondensedBold' size=20><u color=blue>死并非生的对立面，而作为生的一部分永存。</u> <uu color=red>——《挪威的森林》</uu></font></br>"
        text += "<br></br><br></br><br><font face='PingFangSC-Ultralight' size=20 stroke=1>“最最喜欢你，绿子。”</br></font><br>“什么程度？”</br><br>“像喜欢春天的熊一样。”</br><font face='Helvetica' size=20><br>“春天的熊？”绿子再次扬起脸，“什么春天的熊？”</br></font><font face='GillSans-UltraBold' size=20 color='#B95152'><br>“春天的原野里，你一个人正走着，对面走来一只可爱的小熊，浑身的毛活像天鹅绒，眼睛圆鼓鼓的。它这么对你说到：‘你好，小姐，和我一块打滚玩好么？’接着，你就和小熊抱在一起，顺着长满三叶草的山坡咕噜咕噜滚下去，整整玩了一大天。你说棒不棒？”</br></font><br>“太棒了。”</br><font face='HelveticaNeue-CondensedBold' size=20 stroke=1><br>“我就这么喜欢你。”</br></font><br><p align=right><font color=green>——村上春树《挪威的森林》</p></font></br>"
    }
}

extension ViewController: VGLabelDelegate {
    func vgLabel(_ label: VGLabel, didSelectLink url: URL?) {
        print(url ?? "无URL")
    }
}
