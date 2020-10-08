//
//  PolygonView.swift
//  Polygons
//
//  Created by Julia Nikitina on 08.10.2020.
//

import UIKit

final class PolygonView: UIView {
    
    private lazy var polygonLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        
        layer.lineWidth = 3
        
        layer.lineJoin = .round
        layer.strokeColor = UIColor.systemPink.cgColor
        
        layer.fillRule = .evenOdd
        layer.fillColor = UIColor.systemPink.cgColor
        
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(polygonLayer)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        polygonLayer.frame = bounds
    }
    
    func showPolygon(sidesCount: Int) {
        guard let path = makePolygon(sidesCount: sidesCount) else { return }
        polygonLayer.path = path.cgPath
    }

    private func makePolygon(sidesCount: Int) -> UIBezierPath? {
        guard sidesCount > 3 else { return nil }
        
        let path = UIBezierPath()
        
        let width = bounds.width
        
        let contourRectangle = CGRect(x: 0, y: 0, width: width, height: width)
        let center = CGPoint(x: contourRectangle.midX, y: contourRectangle.midY)
        let radius: CGFloat = width * 0.5
        
        var isFirstPoint = true
        
        let pi = CGFloat.pi
        let twoPi = pi * 2
        
        for side in 0..<sidesCount {
            let cgSide = CGFloat(side)
            let cgSideCount = CGFloat(sidesCount)
            let theta = pi + cgSide * twoPi / cgSideCount
            let dTheta = twoPi / cgSideCount
            
            var point = CGPoint()
    
            if isFirstPoint {
                point.x = center.x + radius * sin(theta)
                point.y = center.y + radius * cos(theta)
                path.move(to: point)
                isFirstPoint = false
            }
            
            point.x = center.x + radius * sin(theta + dTheta)
            point.y = center.y + radius * cos(theta + dTheta)
            
            path.addLine(to: point)
        }
        
        path.close()
        return path
    }
}
