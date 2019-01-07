//
//  GFRouteOptionTableViewCell.swift
//  Genfare
//
//  Created by omniwzse on 31/08/18.
//  Copyright © 2018 Genfare. All rights reserved.
//

import UIKit

class GFRouteOptionTableViewCell: UITableViewCell {

    
    @IBOutlet weak var routeNumLabel: UILabel!
    @IBOutlet weak var depInTime: UILabel!
    @IBOutlet weak var depUnits: UILabel!
    @IBOutlet weak var travelTimeLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func reset(){
        currentX = startX
        for view in scrollView.subviews {
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
        
        scrollView.contentSize = CGSize(width: currentX+itemDistance, height: scrollView.frame.size.height)
    }
    
    func attachWalk() {
        let walkImage:UIImageView = UIImageView(image: UIImage(named: "WalkIcon"))
        walkImage.frame = CGRect(x:currentX, y:walkY, width:walkWidth, height:walkHeight)
        scrollView.addSubview(walkImage)
        currentX = walkImage.frame.origin.x + walkImage.frame.size.width + itemDistance
    }
    
    func attachBus(num:String) {
        let busImage:UIImageView = UIImageView(image: UIImage(named: "BusIcon"))
        busImage.frame = CGRect(x: currentX, y: busY, width: busWidth, height: busHeight)
        let label:UILabel = attachLabelTo(bus: busImage,txt: num)
        scrollView.addSubview(label)
        scrollView.addSubview(busImage)
        currentX = busImage.frame.origin.x + busImage.frame.size.width + itemDistance
    }
    
    func attachLabelTo(bus:UIImageView,txt:String) -> UILabel {
        let label:UILabel = UILabel(frame: CGRect(x: bus.frame.origin.x+labelFlowX, y: bus.frame.origin.y-labelFlowY, width: labelWidth, height: labelWidth))
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.white
        label.text = " \(txt) "
        label.sizeToFit()
        styleLabel(label: label)
        return label
    }
    
    func attachArrow() {
        let frame:CGRect = CGRect(x: currentX, y: walkY, width: walkWidth, height: walkHeight)
        let label:UILabel = UILabel(frame: frame)
        label.text = ">"
        label.font = UIFont(name: "HelveticaNeue-UltraLight", size: 15)
        label.textColor = UIColor.buttonBGBlue
        label.sizeToFit()
        scrollView.addSubview(label)
        currentX = label.frame.origin.x + label.frame.size.width + itemDistance
    }
    
    func styleLabel(label:UILabel) {
        label.layer.cornerRadius = label.frame.size.height/2
        //label.layer.masksToBounds = true
        label.layer.backgroundColor = UIColor.buttonBGBlue.cgColor
    }

}
