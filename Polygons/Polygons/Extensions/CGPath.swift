//
//  CGPath.swift
//  Polygons
//
//  Created by Julia Nikitina on 09.10.2020.
//

import UIKit

extension CGPath {
    func points() -> [CGPoint] {
        var bezierPoints = [CGPoint]()
        
        self.forEach { (element: CGPathElement) in
            let numberOfPoints: Int = {
                switch element.type {
                case .moveToPoint, .addLineToPoint: // contains 1 point
                    return 1
                case .addQuadCurveToPoint: // contains 2 points
                    return 2
                case .addCurveToPoint: // contains 3 points
                    return 3
                case .closeSubpath:
                    return 0
                @unknown default:
                    fatalError()
                }
            }()
            for index in 0..<numberOfPoints {
                let point = element.points[index]
                bezierPoints.append(point)
            }
        }
        return bezierPoints
    }

    func forEach(body: @convention(block) @escaping (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        
        func callback(info: UnsafeMutableRawPointer?, element: UnsafePointer<CGPathElement>) {
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: callback as CGPathApplierFunction)
    }
}
