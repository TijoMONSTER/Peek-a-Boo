//
//  UserCollectionViewCell.m
//  Peek-a-Boo
//
//  Created by Iván Mervich on 8/17/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "UserCollectionViewCell.h"
#import "AppDelegate.h"
#import "Photo.h"

@interface UserCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation UserCollectionViewCell

- (void)loadFirstUserImage
{
	NSArray *userPhotos = self.user.photos.allObjects;
	Photo *firstPhoto = userPhotos.firstObject;

	if (firstPhoto) {
		[self showActivityIndicator];

//		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSURL *imageURL = [[self appDelegate].applicationDocumentsDirectory URLByAppendingPathComponent:firstPhoto.fileName];
			NSData *data = [NSData dataWithContentsOfURL:imageURL];
			UIImage *image = [UIImage imageWithData:data];
			self.imageView.image = image;
			[self hideActivityIndicator];
//		});
	}
}

#pragma mark - Helper methods

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)showActivityIndicator
{
	[self.activityIndicator startAnimating];
	[UIView animateWithDuration:0.5 animations:^{
		self.activityIndicator.alpha = 1;
	}];
}

- (void)hideActivityIndicator
{
	[self.activityIndicator stopAnimating];
	[UIView animateWithDuration:0.5 animations:^{
		self.activityIndicator.alpha = 0;
	}];
}

@end
