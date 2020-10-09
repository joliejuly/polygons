//
//  ViewController.swift
//  Polygons
//
//  Created by Julia Nikitina on 08.10.2020.
//

import UIKit

final class ViewController: UIViewController {
     
    private lazy var polygonView: PolygonView = {
        let view = PolygonView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var sidesCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemPink
        label.text = "\(Constants.defaultSidesCount)"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private lazy var sidesStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 4
        stepper.value = Double(Constants.defaultSidesCount)
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        return stepper
    }()
    
    private lazy var distortionSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.maximumTrackTintColor = .systemPink
        slider.minimumTrackTintColor = .lightGray
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        return slider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPolygonView()
        setupStepper()
        setupLabel()
        setupSlider()
    }
    
    private func setupPolygonView() {
        polygonView.setSize(width: 100, height: 100)
        polygonView.addToCenter(of: view)
        
        polygonView.layoutIfNeeded()
        polygonView.showPolygon(sidesCount: Constants.defaultSidesCount)
    }
    
    private func setupStepper() {
        sidesStepper.addToCenter(of: view, excluding: .y)
        sidesStepper.pin(to: [.bottom], of: view, offset: 40)
    }
    
    private func setupSlider() {
        distortionSlider.addToCenter(of: view, excluding: .y)
        distortionSlider.pin(to: [.top, .trailing, .leading], of: view, offset: 50)
    }
    
    private func setupLabel() {
        sidesCountLabel.addToCenter(of: view, excluding: .y)
        sidesCountLabel.pin(to: [.bottom], of: sidesStepper, offset: 4)
    }
    
    @objc private func stepperChanged(_ stepper: UIStepper) {
        let value = Int(sidesStepper.value)
        sidesCountLabel.text = "\(value)"
        update()
    }
    
    @objc private func sliderChanged(_ switch: UISwitch) {
        update()
    }
    
    private func update() {
        let value = Int(sidesStepper.value)
        if distortionSlider.value == 0 {
            polygonView.showPolygon(sidesCount: value)
        } else {
            polygonView.showBlob(sidesCount: value, distortion: distortionSlider.value)
        }
    }
}

extension ViewController {
    private enum Constants {
        static let defaultSidesCount = 6
    }
}
