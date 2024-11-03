//
//  WeekdayTransformer.swift
//  Tracker
//
//  Created by big stepper on 30/10/2024.
//

import Foundation


@objc
public final class DaysValueTransformer: ValueTransformer {
    
    public override class func transformedValueClass() -> AnyClass { NSData.self }
    public override class func allowsReverseTransformation() -> Bool { true }
    
    public override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [Weekday] else { return nil }
        return try? JSONEncoder().encode(days)
    }
    
    public override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([Weekday].self, from: data as Data)
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(String(describing: DaysValueTransformer.self))
        )
    }
}
