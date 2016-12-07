//
//  ViewController.swift
//  Colores
//
//  Created by Timple Soft on 24/11/16.
//  Copyright © 2016 TimpleSoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var btnSwitch: UIButton!
    @IBOutlet weak var imgKnobBase: UIImageView!
    @IBOutlet weak var imgKnob: UIImageView!
    
    private var deltaAngle: CGFloat?
    private var startTransform: CGAffineTransform?
    
    // el punto de arriba
    private var setPointAngle = M_PI_2
    
    // establecemos nuestros límites tomando como referencia un ángulo de 30º
    private let maxAngle = 7*M_PI / 6
    private let minAngle = 0 - (M_PI/6)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgKnob.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnSwitch.setImage(#imageLiteral(resourceName: "img_switch_off"), for: .normal)
        btnSwitch.setImage(#imageLiteral(resourceName: "img_switch_on"), for: .selected)
    }

    @IBAction func switchPressed(_ sender: UIButton) {
        btnSwitch.isSelected = !btnSwitch.isSelected
        if btnSwitch.isSelected {
            resetKnob()
            imgKnob.isHidden = false
            imgKnobBase.isHidden = false
        } else {
            view.backgroundColor = UIColor(hue: 0.5, saturation: 0, brightness: 0.2, alpha: 1.0)
            imgKnob.isHidden = true
            imgKnobBase.isHidden = true
        }
    }
    
    
    private func resetKnob() {
        view.backgroundColor = UIColor(hue: 0.5, saturation: 0.5, brightness: 0.75, alpha: 1.0)
        imgKnob.transform = CGAffineTransform.identity
        setPointAngle = M_PI_2
    }
    
    
    private func touchIsInKnob(distance: CGFloat) -> Bool {
        if distance > imgKnob.bounds.height/2 {
            return false
        }
        return true
    }
    
    // teorema de pitágoras
    private func calculateDistanceFromCenter(_ point: CGPoint) -> CGFloat{
        let center = CGPoint(x: imgKnob.bounds.size.width/2.0, y: imgKnob.bounds.size.height/2.0)
        let dx = point.x - center.x
        let dy = point.y - center.y
        return sqrt((dx*dy) + (dx*dy))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            let delta = touch.location(in: imgKnob)
            let dist = calculateDistanceFromCenter(delta)
            if touchIsInKnob(distance: dist) {
                startTransform = imgKnob.transform
                let center = CGPoint(x: imgKnob.bounds.size.width/2.0, y: imgKnob.bounds.size.height/2.0)
                let deltaX = delta.x - center.x
                let deltaY = delta.y - center.y
                deltaAngle = atan2(deltaY, deltaX)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if let touch = touches.first {
            if touch.view == imgKnob{
                deltaAngle = nil
                startTransform = nil
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let touch = touches.first,
            let deltaAngle = deltaAngle,
            let startTransform = startTransform,
            touch.view == imgKnob{
            
            let position = touch.location(in: imgKnob)
            let dist = calculateDistanceFromCenter(position)
            if touchIsInKnob(distance: dist) {
                
                // vamoss a calcular el ángulo según arrastramos
                let center = CGPoint(x: imgKnob.bounds.size.width/2.0, y: imgKnob.bounds.size.height/2.0)
                let deltaX = position.x - center.x
                let deltaY = position.y - center.y
                let angle = atan2(deltaY, deltaX)
                
                // calculamos la distancia con el anterior
                let angleDif = deltaAngle - angle
                
                let newTransform = startTransform.rotated(by: -angleDif)
                let lastSetPointAngle = setPointAngle
                
                // comprobamos que no nos hemos pasado de los límites
                // al anterior le sumamos lo que nos hemos movido
                setPointAngle = setPointAngle + Double(angleDif)
                if setPointAngle >= minAngle && setPointAngle <= maxAngle {
                    
                    // cambiamos el color y le aplicamos la transformada
                    view.backgroundColor = UIColor(hue: colorValueFromAngle(angle: setPointAngle), saturation: 0.5, brightness: 0.75, alpha: 1.0)
                    imgKnob.transform = newTransform
                    self.startTransform = newTransform
                    
                } else {
                    
                    // si se pasa, lo dejamos en el límite
                    setPointAngle = lastSetPointAngle
                    
                }
                
            }
            
        }
        
    }
    
    
    private func colorValueFromAngle(angle: Double) -> CGFloat {
        
        let hueValue = (angle - minAngle) * (360 / (maxAngle - minAngle))
        return CGFloat(hueValue/360)
        
    }
    
    
}

