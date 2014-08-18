//
//  AddUserViewController.m
//  Peek-a-Boo
//
//  Created by Iván Mervich on 8/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "AddUserViewController.h"
#import "AppDelegate.h"
#import "User.h"
#import "Photo.h"

#define doneAddingUserSegue @"doneAddingUserSegue"

@interface AddUserViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;

@property BOOL photoWasSet;
@property UIImage *selectedImage;

@end

@implementation AddUserViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.hidesBackButton = YES;
}

#pragma mark - IBActions

- (IBAction)textFieldDidEndOnExit:(UITextField *)sender
{
	[sender resignFirstResponder];
}

- (IBAction)onDoneButtonTapped:(UIBarButtonItem *)sender
{
	// if any textfield or the imageview is empty
	if ([self textFieldIsEmpty:self.nameTextField] ||
		[self textFieldIsEmpty:self.phoneTextField] ||
		[self textFieldIsEmpty:self.addressTextField] ||
		[self textFieldIsEmpty:self.emailTextField] ||
		!self.photoWasSet) {

		[self showAlertViewWithTitle:@"Can't add user" message:@"Fields must not be empty" buttonTitle:@"OK"];
	} else {
		User *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[self managedObjectContext]];
		newUser.name = self.nameTextField.text;
		newUser.phone = self.nameTextField.text;
		newUser.address = self.addressTextField.text;
		newUser.email = self.emailTextField.text;

		// create photos object
		Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:[self managedObjectContext]];
		newPhoto.fileName = [NSString stringWithFormat:@"%@_photo_1.png", self.emailTextField.text];

		// save it on documents dir with name: email + "_photo_1"
		NSURL *imageURL = [[self appDelegate].applicationDocumentsDirectory URLByAppendingPathComponent:newPhoto.fileName];
		NSData *imageData = UIImagePNGRepresentation(self.selectedImage);

		// save it on a background thread
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[imageData writeToURL:imageURL atomically:YES];
		});

		// add photo to user
		[newUser addPhotosObject:newPhoto];
		// save context
		[self saveContext];
	}
}

- (IBAction)onImageViewTapped:(UITapGestureRecognizer *)tapGestureRecognizer
{
	UIImagePickerController *imagePicker = [UIImagePickerController new];
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePicker.delegate = self;

	[self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	self.selectedImage = info[UIImagePickerControllerOriginalImage];
	self.imageView.image = self.selectedImage;
	self.photoWasSet = YES;

	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
	self.selectedImage = nil;
	self.imageView.image = [UIImage imageNamed:@"picture"];
	self.photoWasSet = NO;
}

#pragma mark - Helper methods

- (BOOL)textFieldIsEmpty:(UITextField *)textField
{
	return textField.text.length == 0;
}

- (void)saveContext
{
//	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError *saveError;
		[[self managedObjectContext] save:&saveError];

		if (saveError) {
			[self showAlertViewWithTitle:@"Saving dog error" message:saveError.localizedDescription buttonTitle:@"OK"];
			NSLog(@"Saving dog error: %@", saveError.localizedDescription);
		} else {
			NSLog(@"context saved");
		}

		[self.navigationController popViewControllerAnimated:YES];
		// reload users collectionView
		[[NSNotificationCenter defaultCenter] postNotificationName:@"AddedUserNotification" object:nil];
//	});
}

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [self appDelegate].managedObjectContext;
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