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
        stepper.minimumValue = 3
        stepper.value = Double(Constants.defaultSidesCount)
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        return stepper
    }()
    
    private lazy var blobSwitch: UISwitch = {
        let switcher = UISwitch()
        switcher.tintColor = .systemPink
        switcher.onTintColor = .systemPink
        switcher.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        return switcher
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPolygonView()
        setupStepper()
        setupLabel()
        setupSwitch()
    }
    
    private func setupPolygonView() {
        polygonView.setSize(width: 300, height: 300)
        polygonView.addToCenter(of: view)
        
        polygonView.layoutIfNeeded()
        polygonView.showPolygon(sidesCount: Constants.defaultSidesCount)
    }
    
    private func setupStepper() {
        sidesStepper.addToCenter(of: view, excluding: .y)
        sidesStepper.pin(to: [.bottom], of: view, offset: 40)
    }
    
    private func setupLabel() {
        sidesCountLabel.addToCenter(of: view, excluding: .y)
        sidesCountLabel.pin(to: [.bottom], of: sidesStepper, offset: 4)
    }
    
    private func setupSwitch() {
        blobSwitch.addToCenter(of: view, excluding: .y)
        blobSwitch.pin(to: [.top], of: view, offset: 50)
    }
    
    @objc private func stepperChanged(_ stepper: UIStepper) {
        let value = Int(stepper.value)
        sidesCountLabel.text = "\(value)"
        if blobSwitch.isOn {
            polygonView.showBlob(sidesCount: value)
        } else {
            polygonView.showPolygon(sidesCount: value)
        }
    }
    
    @objc private func switchChanged(_ switch: UISwitch) {
        let value = Int(sidesStepper.value)
        if blobSwitch.isOn {
            polygonView.showBlob(sidesCount: value)
        } else {
            polygonView.showPolygon(sidesCount: value)
        }
    }
}

extension ViewController {
    private enum Constants {
        static let defaultSidesCount = 6
    }
}
