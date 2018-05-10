//
//  LSCircleProgressView.swift
//  WhoCallMe
//
//  Created by 영준 이 on 2016. 4. 16..
//  Copyright © 2016년 leesam. All rights reserved.
//

import UIKit
import CoreGraphics

@IBDesignable
class LSCircleProgressView: UIView {

    /**
        0.0...1.0, default is 0.0. values outside are pinned.
    */
    @IBInspectable
    var progress: Float = 0.0{
        didSet{
            if self.progress < 0{
                self.progress = 0;
            }
            
            if self.progress > 1{
                self.progress = 1;
            }
            
            self.setNeedsDisplay();
        }
    }
    
    var padding: Float = 0.0{
        didSet{
            
        }
    }
    
    @IBInspectable
    var progressTintColor: UIColor! = UIColor.blue{
        didSet{
            self.setNeedsDisplay();
        }
    }
    
    @IBInspectable
    var trackTintColor: UIColor! = UIColor.clear{
        didSet{
            self.setNeedsDisplay();
        }
    }
    
    @IBInspectable
    var barWidth: CGFloat = 20{
        didSet{
            self.setNeedsDisplay();
        }
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        /*for view in self.subviews{
            view.removeFromSuperview();
        }*/
    }
    
    static let maxAngle : Double = 360.0;
    @IBInspectable
    var startAngle : Double = -90{
        didSet{
            switch self.direction{
            case .right:
                if self.endAngle - self.startAngle > type(of: self).maxAngle{
                    self.startAngle = self.endAngle - type(of: self).maxAngle;
                }
                break;
            case .left:
                if self.startAngle - self.endAngle > type(of: self).maxAngle{
                    self.startAngle = self.endAngle + type(of: self).maxAngle;
                }
                break;
            }
            
            self.setNeedsDisplay();
        }
    }

    @IBInspectable
    var endAngle : Double = -90 + maxAngle{
        didSet{
            switch self.direction{
                case .right:
                    if self.endAngle - self.startAngle > type(of: self).maxAngle{
                        self.endAngle = self.startAngle - type(of: self).maxAngle;
                    }
                    break;
                case .left:
                    if self.startAngle - self.endAngle > type(of: self).maxAngle{
                        self.endAngle = self.startAngle + type(of: self).maxAngle;
                    }
                    break;
            }
            
            self.setNeedsDisplay();
        }
    }
    
    enum Direction: Int{
        case right = 1
        case left = -1
    }
    var direction : Direction = .right{
        didSet{
            self.setNeedsDisplay();
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        guard let ctx = UIGraphicsGetCurrentContext() else{
            return;
        }
        
        var angle = self.direction == .right ? (self.endAngle - self.startAngle) : (self.startAngle - self.endAngle);
        angle = Double(self.progress) * angle;
        //let endAngle = startAngle + Double(self.progress) * 360.0;
        let startRadian = self.startAngle / 180.0 * Double.pi;
        let progRadian = (self.startAngle + angle) / 180.0 * Double.pi;
        let endRadian = self.endAngle / 180.0 * Double.pi;
        
        let center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2);
        
        //creates track
        /*ctx.beginPath();
        ctx.move(to: CGPoint(x: center.x, y: center.y));
        ctx.addArc(center: center, radius: self.frame.width / 2, startAngle: CGFloat(startRadian), endAngle: CGFloat(endRadian), clockwise: false);
        
        ctx.setFillColor(self.trackTintColor.cgColor);
        ctx.fillPath();
        ctx.closePath();*/
        
        // MARK: draw with clipping
        //draw progress
        //ctx.beginPath();
        ctx.saveGState();
        //substract hole arc
        ctx.move(to: CGPoint(x: center.x, y: center.y));
        ctx.addArc(center: center, radius: self.frame.width / 2 - self.barWidth, startAngle: CGFloat(startRadian), endAngle: CGFloat(endRadian), clockwise: false);
        ctx.closePath();
        ctx.addArc(center: center, radius: self.frame.width / 2, startAngle: CGFloat(startRadian), endAngle: CGFloat(progRadian), clockwise: false);
        //ctx.addRect(ctx.boundingBoxOfClipPath);
        ctx.clip(using: .evenOdd);
        
        //ctx.move(to: CGPoint(x: center.x, y: center.y));
        //ctx.addArc(center: center, radius: self.frame.width / 2, startAngle: CGFloat(startRadian), endAngle: CGFloat(progRadian), clockwise: false);
        let color = self.progressTintColor == nil ? self.tintColor : self.progressTintColor;
        color?.setFill();
        ctx.fill(ctx.boundingBoxOfClipPath);
        ctx.restoreGState();
        return;
        
        // MARK: draw with bezier
        /*let path = UIBezierPath.init(arcCenter: center, radius: self.frame.width / 2 - self.barWidth, startAngle: CGFloat(startRadian), endAngle: CGFloat(progRadian), clockwise: true);
        path.addArc(withCenter: center, radius: self.frame.width / 2, startAngle: CGFloat(progRadian), endAngle:  CGFloat(startRadian), clockwise: false);
        path.close();
        
        let color = self.progressTintColor == nil ? self.tintColor : self.progressTintColor;
        color?.setFill()
        path.fill();
        ctx.closePath();*/
        
        //print("draw arc frame[\(self.frame)] color[\(self.tintColor.cgColor)] start[\(startRadian)] end[\(endRadian)]");
        //self.clipsToBounds = true;
    }

}
