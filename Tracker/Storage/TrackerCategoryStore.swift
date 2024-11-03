//
//  TrackerCategoryStorage.swift
//  Tracker
//
//  Created by big stepper on 30/10/2024.
//

import UIKit
import CoreData


final class TrackerCategoryStorage {
    
    //MARK: - Properties
    
    private var context: NSManagedObjectContext
    
    //MARK: - Init
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    //MARK: - Methods
    

}
