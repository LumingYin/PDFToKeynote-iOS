//
//  ModernFluidTableView.swift
//  ModernUIKit
//
//  Created by Cliff Panos on 10/2/18.
//  Copyright © 2019 Clifford Panos. All rights reserved.
//

import UIKit

///
/// A table view whose gesture recognizers are setup to allow more dynamic interaction when nested in other views
///
class ModernFluidTableView: UITableView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.panGestureRecognizer.delegate = self
    }

}


// MARK: - UIGestureRecognizerDelegate

extension ModernFluidTableView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // We only want the table view AND collection view gestures to recognize simultaneously when
        // we have swiped on the collection view and it is still continuing to scroll when suddenly
        // we swipe in a semi-vertical direction and want the table view to be able to scroll at this time
        // even while the collection view is finishing its scroll animation
        return otherGestureRecognizer.state == .began
    }
    
}
