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
        layer.miterLimit = 100
        
        layer.lineJoin = .round
        layer.lineCap = .round
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
    
    func showBlob(sidesCount: Int) {
        guard let path = makeBlob(sidesCount:sidesCount) else { return }
        
        let smoothed = catmullRomSmoothPath(path: path)
        polygonLayer.path = smoothed?.cgPath
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
    
    
    private func makeBlob(sidesCount: Int) -> UIBezierPath? {
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
            
            let percent: CGFloat = CGFloat.random(in: -1...1)
            let blobRadius: CGFloat = CGFloat.random(in: radius...radius * 1.5) * (1 + percent)
            
            let cgSide = CGFloat(side)
            let cgSideCount = CGFloat(sidesCount)
            let theta = pi + cgSide * twoPi / cgSideCount
            let dTheta = twoPi / cgSideCount
            
    
            if isFirstPoint {
                var point = CGPoint()
                point.x = center.x + radius * sin(theta)
                point.y = center.y + radius * cos(theta)
                path.move(to: point)
                isFirstPoint = false
            }
            
            var controlPoint1 = CGPoint()
            
            controlPoint1.x = center.x + blobRadius * sin(theta + dTheta / 3)
            controlPoint1.y = center.y + blobRadius * cos(theta + dTheta / 3)
            
            var controlPoint2 = CGPoint()
            
            controlPoint2.x = center.x + blobRadius * sin(theta + 2 * dTheta / 3)
            controlPoint2.y = center.y + blobRadius * cos(theta + 2 * dTheta / 3)

            
            var point = CGPoint()
            point.x = center.x + radius * sin(theta + dTheta)
            point.y = center.y + radius * cos(theta + dTheta)
            
            path.addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
        
        path.close()
        return path
    }
    
    private func catmullRomSmoothPath(path: UIBezierPath?) -> UIBezierPath? {
        guard let path = path else { return nil }
        
        let granularity = 100
        
        var points = path.cgPath.points()
        
        points.insert(points.first!, at: 0)
        points.append(points.last!)
        
        let smoothedPath = UIBezierPath()
        smoothedPath.lineWidth = path.lineWidth
        
        // draw first three points
        
        smoothedPath.move(to: points.first!)
        
        for index in 1...3 {
            let point = points[index]
            smoothedPath.addLine(to: point)
        }
        
        // draw other points
        
        for index in 4..<points.count {
            let point0 = points[index - 3]
            let point1 = points[index - 2]
            let point2 = points[index - 1]
            let point3 = points[index]
            
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
        
        smoothedPath.addLine(to: points.last!)
        
        return smoothedPath
    }
}
