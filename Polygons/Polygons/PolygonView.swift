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
        
        layer.lineWidth = 5
        layer.miterLimit = 0
        
        layer.lineJoin = .round
        layer.lineCap = .round
        layer.strokeColor = UIColor.systemPink.cgColor
        layer.contentsScale = UIScreen.main.nativeScale
        
        layer.fillColor = UIColor.white.cgColor
        
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
    
    func showBlob(sidesCount: Int, distortion: Float) {
        let path = makeBlobTemplate(sidesCount: sidesCount, distortion: distortion)
        //polygonLayer.path = path?.cgPath

        let smoothed = catmullRomSmoothPath(path: path!)
        polygonLayer.path = smoothed?.cgPath
    }

    private func makePolygon(sidesCount: Int) -> UIBezierPath? {
        guard sidesCount > 3 else { return nil }
        
        let path = UIBezierPath()
        
        let width = bounds.width
        
        let contourRectangle = CGRect(x: 0, y: 0, width: width, height: width)
        let center = CGPoint(x: contourRectangle.midX, y: contourRectangle.midY)
        let radius: CGFloat = width
        
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
    
    private func makeBlobTemplate(sidesCount: Int, distortion: Float) -> UIBezierPath? {
        guard sidesCount > 3 else { return nil }
        let cgDistortion = CGFloat(distortion)
        let path = UIBezierPath()
        
        let width = bounds.width
        
        let contourRectangle = CGRect(x: 0, y: 0, width: width, height: width)
        let center = CGPoint(x: contourRectangle.midX, y: contourRectangle.midY)
        
        let pi = CGFloat.pi
        let twoPi = pi * 2
        
        var firstPoint = CGPoint()
        
        for side in 0..<sidesCount {
            
            let radius: CGFloat = width - width * CGFloat.random(in: 0...cgDistortion)
            
            let cgSide = CGFloat(side)
            let cgSideCount = CGFloat(sidesCount)
            let theta = pi + cgSide * twoPi / cgSideCount
            let dTheta = twoPi / cgSideCount
            
            if side == 0 {
                var point = CGPoint()
                
                point.x = center.x + radius * sin(theta)
                point.y = center.y + radius * cos(theta)
                
                path.move(to: point)
                firstPoint = point
            }
            
            var point = CGPoint()
            point.x = center.x + radius * sin(theta + dTheta)
            point.y = center.y + radius * cos(theta + dTheta)
            
            
            if side == sidesCount - 1 {
                path.addLine(to: firstPoint)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.close()
        return path
    }
    
    private func catmullRomSmoothPath(path: UIBezierPath?, isClosed: Bool = true) -> UIBezierPath? {
        guard let path = path else { return nil }
    
        var points = path.cgPath.points()
        guard points.count >= 4 else { return nil }
        
        let granularity = 20
        
        let smoothedPath = UIBezierPath()
        smoothedPath.lineWidth = path.lineWidth
        
        // draw other points
        
        for index in 0..<points.count {
//            let point0 = points[index - 3]
//            let point1 = points[index - 2]
//            let point2 = points[index - 1]
//            let point3 = points[index]
            
            let point0 = points[index - 1 < 0 ? points.count - 1 : index - 1]
            let point1 = points[index]
            let point2 = points[(index + 1) % points.count]
            let point3 = points[(index + 2) % points.count]
            
            if index == 0 {
                smoothedPath.move(to: point0)
            }
            
            for granularityValue in 1..<granularity {
                let t = CGFloat(granularityValue) * (1.0 / CGFloat(granularity))
                let tt = t * t
                let ttt = tt * t
                
                // intermediate point
                var point = CGPoint()
                
                let xPlain = 2 * point1.x + (point2.x - point0.x) * t
                let xQuadripled = (2 * point0.x - 5 * point1.x + 4 * point2.x - point3.x) * tt
                let xCubed = (3 * point1.x - point0.x - 3 * point2.x + point3.x) * ttt
    
                point.x = 0.5 * (xPlain + xQuadripled + xCubed)
                
                
                let yPlain = 2 * point1.y + (point2.y - point0.y) * t
                let yQuadripled = (2 * point0.y - 5 * point1.y + 4 * point2.y - point3.y) * tt
                let yCubed = (3 * point1.y - point0.y - 3 * point2.y + point3.y) * ttt
                
                point.y = 0.5 * (yPlain + yQuadripled + yCubed)
                
                smoothedPath.addLine(to: point)
            }
            
            smoothedPath.addLine(to: point2)
        }
        
        //smoothedPath.addLine(to: points.last!)
        
        return smoothedPath
    }
}
