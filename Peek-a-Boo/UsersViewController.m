//
//  UsersViewController.m
//  Peek-a-Boo
//
//  Created by Iván Mervich on 8/15/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "UsersViewController.h"

@interface UsersViewController () <UICollectionViewDataSource>

@end

@implementation UsersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UICollectionView Data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

#pragma mark - Navigation

- (IBAction)unwindFromAddUserViewController:(UIStoryboardSegue *)segue
{

}

@end
