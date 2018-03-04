//
//  OpencvWrapper.h
//  face_detection
//
//  Created by Soubhi Hadri on 3/3/18.
//  Copyright © 2018 hadri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface OpencvWrapper : NSObject
+ (UIImage *)detect:(UIImage *)source;
@end
