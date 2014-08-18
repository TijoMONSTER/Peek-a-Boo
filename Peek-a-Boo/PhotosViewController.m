//
//  PhotosViewController.m
//  Peek-a-Boo
//
//  Created by Iván Mervich on 8/17/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "PhotosViewController.h"
#import "Photo.h"
#import "AppDelegate.h"

@interface PhotosViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation PhotosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	CGFloat width = 0.0;

	for (Photo *photo in self.user.photos.allObjects) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[self imageWithFileName:photo.fileName]];
		imageView.frame = CGRectMake(width, 0, self.view.frame.size.width, self.view.frame.size.height);
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		width += imageView.frame.size.width;

		[self.scrollView addSubview:imageView];
	}

	self.scrollView.contentSize = CGSizeMake(width, self.scrollView.frame.size.height);

	self.nameLabel.text = self.user.name;
	self.phoneLabel.text = self.user.phone;
	self.addressLabel.text = self.user.address;
	self.emailLabel.text = self.user.email;
}

- (UIImage *)imageWithFileName:(NSString *)fileName
{
	NSURL *imageURL = [[self appDelegate].applicationDocumentsDirectory URLByAppendingPathComponent:fileName];
	NSData *data = [NSData dataWithContentsOfURL:imageURL];
	return [UIImage imageWithData:data];
}

#pragma mark - Helper methods

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
