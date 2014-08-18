//
//  UserCollectionViewCell.h
//  Peek-a-Boo
//
//  Created by Iván Mervich on 8/17/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserCollectionViewCell : UICollectionViewCell

@property User *user;

- (void)loadFirstUserImage;

@end