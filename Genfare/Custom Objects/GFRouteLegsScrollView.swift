//
//  GFRouteLegsScrollView.swift
//  Genfare
//
//  Created by omniwzse on 12/09/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFRouteLegsScrollView: UIScrollView {

    let startX:CGFloat = 4
    let walkWidth:CGFloat = 20
    let walkHeight:CGFloat = 20
    let walkY:CGFloat = 12
    let busWidth:CGFloat = 20
    let busHeight:CGFloat = 20
    let busY:CGFloat = 12
    let labelFlowX:CGFloat = 10
    let labelFlowY:CGFloat = 11
    let labelWidth:CGFloat = 10
    
    let itemDistance:CGFloat = 15
    
    var currentX:CGFloat = 0

    func reset(){
        currentX = startX
        for view in subviews {
            view.removeFromSuperview()
        }
    }

    func attachRouteItems(route:GFRoute) {
        for i in 0...(route.legsList!.count - 1) {
            let leg:GFRouteLeg = route.legsList![i]
            if leg.mode == Constants.TransitMode.Walk {
                attachWalk()
            }
            if leg.mode == Constants.TransitMode.Bus {
                attachBus(num: leg.routeNumber!)
            }
            if i < ((route.legsList?.count)!-1) {
                attachArrow()
            }
        }
        
        contentSize = CGSize(width: currentX+itemDistance, height: frame.size.height)
    }

    private func attachWalk() {
        let walkImage:UIImageView = UIImageView(image: UIImage(named: "WalkIcon"))
        walkImage.frame = CGRect(x:currentX, y:walkY, width:walkWidth, height:walkHeight)
        addSubview(walkImage)
        currentX = walkImage.frame.origin.x + walkImage.frame.size.width + itemDistance
    }
    
    private func attachBus(num:String) {
        let busImage:UIImageView = UIImageView(image: UIImage(named: "BusIcon"))
        busImage.frame = CGRect(x: currentX, y: busY, width: busWidth, height: busHeight)
        let label:UILabel = attachLabelTo(bus: busImage,txt: num)
        addSubview(label)
        addSubview(busImage)
        currentX = busImage.frame.origin.x + busImage.frame.size.width + itemDistance
    }
    
    private func attachLabelTo(bus:UIImageView,txt:String) -> UILabel {
        let label:UILabel = UILabel(frame: CGRect(x: bus.frame.origin.x+labelFlowX, y: bus.frame.origin.y-labelFlowY, width: labelWidth, height: labelWidth))
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.white
        label.text = " \(txt) "
        label.sizeToFit()
        styleLabel(label: label)
        return label
    }
    
    private func attachArrow() {
        let frame:CGRect = CGRect(x: currentX, y: walkY, width: walkWidth, height: walkHeight)
        let label:UILabel = UILabel(frame: frame)
        label.text = ">"
        label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 15)
        label.textColor = UIColor.buttonBGBlue
        label.sizeToFit()
        addSubview(label)
        currentX = label.frame.origin.x + label.frame.size.width + itemDistance
    }
    
    private func styleLabel(label:UILabel) {
        label.layer.cornerRadius = label.frame.size.height/2
        label.layer.backgroundColor = UIColor.buttonBGBlue.cgColor
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
