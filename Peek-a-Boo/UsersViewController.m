//
//  UsersViewController.m
//  Peek-a-Boo
//
//  Created by Iván Mervich on 8/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "UsersViewController.h"
#import "AppDelegate.h"
#import "User.h"
#import "Photo.h"
#import "UserCollectionViewCell.h"

@interface UsersViewController () <UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property NSFetchedResultsController *fetchedResultsController;

@end

@implementation UsersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"User"];
	fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

	self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
																		managedObjectContext:[self managedObjectContext]
																		  sectionNameKeyPath:nil
																				   cacheName:nil];
	[self performFetch];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAddedUser:) name:@"AddedUserNotification" object:nil];
}

#pragma mark - UICollectionView Data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.fetchedResultsController.sections[section] numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	User *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
	UserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
	cell.user = user;
	[cell loadFirstUserImage];

	return cell;
}

#pragma mark - Notifications

- (void)onAddedUser:(NSNotification *)notification
{
	// reload collectionView after adding user
	[self performFetch];
}

#pragma mark - Helper methods

- (AppDelegate *)appDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [self appDelegate].managedObjectContext;
}

- (void)performFetch
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError *fetchError;
		[self.fetchedResultsController performFetch:&fetchError];

		if (fetchError) {
			[self showAlertViewWithTitle:@"Fetch error" message:fetchError.localizedDescription buttonTitle:@"OK"];
			NSLog(@"user fetch error: %@", fetchError.localizedDescription);
		} else {
			[self.collectionView reloadData];
		}

	});
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
