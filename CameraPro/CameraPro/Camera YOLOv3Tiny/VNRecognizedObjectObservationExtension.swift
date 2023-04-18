//
//  VNRecognizedObjectObservationExtension.swift
//  CameraPro
//
//  Created by Николай Мартынов on 09.07.2021.
//

import Vision

extension VNRecognizedObjectObservation {
    var label: String? {
        return self.labels.first?.identifier
    }
}

