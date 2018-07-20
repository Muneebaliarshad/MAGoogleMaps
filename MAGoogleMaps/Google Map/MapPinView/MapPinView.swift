//
//  TracksPinView.swift
//  Tryp
//
//  Created by Muneeb Ali on 04/07/2018.
//  Copyright © 2018 Ingic. All rights reserved.
//

import UIKit

class MapPinView: UIView {

    //MARK: - IBOutlets
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var pinTextView: UIView!
    @IBOutlet weak var pinLineView: UIView!
    @IBOutlet weak var mapPinImageView: UIImageView!
    @IBOutlet weak var visitedNumberLabel: UILabel!
    
    
    //MARK: - Variables
    
    
    //MARK: - UIView Init Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    //MARK: - Helper Methods
    
    private func nibSetup() {
        
        self.view = loadViewFromNib()
        self.view.frame = bounds
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.translatesAutoresizingMaskIntoConstraints = true
        self.view.layer.cornerRadius = 25
        self.addSubview(view)
        
    }
    
    
    private func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return nibView
    }
    
    
    
    func setupViewData() {
    }

}
