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

@interface PhotosViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (weak, nonatomic) IBOutlet UIView *editUserInfoView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property UIImageView *selectedImageView;

@end

@implementation PhotosViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self addPhotosToScrollView];

	self.nameLabel.text = self.user.name;
	self.phoneLabel.text = self.user.phone;
	self.addressLabel.text = self.user.address;
	self.emailLabel.text = self.user.email;

	self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.editUserInfoView.alpha = 0;
}

#pragma mark - IBActions

- (IBAction)onAddPhotoButtonTapped:(UIBarButtonItem *)sender
{
	for (UIView *view in self.scrollView.subviews) {
		for (UIGestureRecognizer *gestureRecognizer in view.gestureRecognizers) {
			[view removeGestureRecognizer:gestureRecognizer];
		}

		[view removeFromSuperview];
	}

	// add photo to user
	UIImagePickerController *imagePicker = [UIImagePickerController new];
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePicker.delegate = self;

	[self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)onImageViewTapped:(UITapGestureRecognizer *)tapGestureRecognizer
{
	self.selectedImageView = (UIImageView *)tapGestureRecognizer.view;

	self.nameTextField.text = self.user.name;
	self.phoneTextField.text = self.user.phone;
	self.addressTextField.text = self.user.address;
	self.emailTextField.text = self.user.email;

	[UIView transitionWithView:self.selectedImageView duration:0.5
					   options:UIViewAnimationOptionTransitionFlipFromLeft
					animations:^{
						self.selectedImageView.alpha = 0.0;
						self.detailView.alpha = 0.0;
						self.editUserInfoView.alpha = 1.0;
						self.navigationController.navigationBarHidden = YES;
					}
					completion:nil];

}

- (IBAction)onSaveButtonTapped:(UIButton *)sender
{
	self.user.name = self.nameTextField.text;
	self.user.phone = self.phoneTextField.text;
	self.user.address = self.addressTextField.text;
	self.user.email = self.emailTextField.text;

	// save the user's new data into core data
	[self saveContext];

	// set the detail view labels
	self.nameLabel.text = self.user.name;
	self.phoneLabel.text = self.user.phone;
	self.addressLabel.text = self.user.address;
	self.emailLabel.text = self.user.email;

	// hide the keyboard
	[self.nameTextField resignFirstResponder];
	[self.phoneTextField resignFirstResponder];
	[self.addressTextField resignFirstResponder];
	[self.emailTextField resignFirstResponder];

	[UIView transitionWithView:self.selectedImageView
					  duration:0.5
					   options:UIViewAnimationOptionTransitionFlipFromRight
					animations:^{
						self.selectedImageView.alpha = 1.0;
						self.detailView.alpha = 0.5;
						self.editUserInfoView.alpha = 0.0;
						self.navigationController.navigationBarHidden = NO;
					}
					completion:nil];

	self.selectedImageView = nil;
}

- (IBAction)textFieldDidEndOnExit:(UITextField *)sender
{
	[sender resignFirstResponder];
}

#pragma mark - UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[self dismissViewControllerAnimated:YES completion:nil];

	UIImage *image = info[UIImagePickerControllerOriginalImage];

	// create photos object
	Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:[self managedObjectContext]];
	newPhoto.fileName = [NSString stringWithFormat:@"%@_photo_%d.png", self.user.email, self.user.photos.count + 1];
	NSLog(@"new photo name: %@", newPhoto.fileName);

	// save it on documents dir with name: email + "_photo_1"
	NSURL *imageURL = [[self appDelegate].applicationDocumentsDirectory URLByAppendingPathComponent:newPhoto.fileName];
	NSData *imageData = UIImagePNGRepresentation(image);

	// save it on a background thread
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[imageData writeToURL:imageURL atomically:YES];
		NSLog(@"new image saved");
	});

	// add photo to user
	[self.user addPhotosObject:newPhoto];
	// save context
	[self saveContext];

	[self addPhotosToScrollView];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"showAddressSegue"]) {
		
	}
}

#pragma mark - Helper methods

- (UIImage *)imageWithFileName:(NSString *)fileName
{
	NSURL *imageURL = [[self appDelegate].applicationDocumentsDirectory URLByAppendingPathComponent:fileName];
	NSData *data = [NSData dataWithContentsOfURL:imageURL];
	return [UIImage imageWithData:data];
}

- (void)addPhotosToScrollView
{
	CGFloat width = 0.0;

	for (Photo *photo in self.user.photos.allObjects) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[self imageWithFileName:photo.fileName]];
		[self.scrollView addSubview:imageView];

		imageView.userInteractionEnabled = YES;
		imageView.frame = CGRectMake(width, 0, self.view.frame.size.width, self.view.frame.size.height);
		imageView.contentMode = UIViewContentModeScaleAspectFit;
		width += imageView.frame.size.width;

		UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
																				action:@selector(onImageViewTapped:)];
		tapGR.numberOfTapsRequired = 1;
		[imageView addGestureRecognizer:tapGR];
	}

	self.scrollView.contentSize = CGSizeMake(width, self.scrollView.frame.size.height);
}

- (void)saveContext
{
	NSError *saveError;
	[[self managedObjectContext] save:&saveError];

	if (saveError) {
		[self showAlertViewWithTitle:@"Saving dog error" message:saveError.localizedDescription buttonTitle:@"OK"];
		NSLog(@"Saving dog error: %@", saveError.localizedDescription);
	} else {
		NSLog(@"context saved");
	}

}

- (NSManagedObjectContext *)managedObjectContext
{
	return [self appDelegate].managedObjectContext;
}

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
														message:message
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:buttonTitle, nil];
	[alertView show];
}

@end
