//
//  CollectionViewController.m
//  Imaginator
//
//  Created by Фёдор Морев on 7/28/19.
//  Copyright © 2019 Фёдор Морев. All rights reserved.
//

#import "../../utils/Colors.h"
#import "../../utils/Controllers.h"
#import "CollectionViewCell.h"
#import "../DetailsViewController.h"
#import "CollectionViewController.h"

@interface CollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property(retain, nonatomic) NSMutableArray *dataModel;
@property(retain, nonatomic) NSOperationQueue *customQueue;
@property(retain, nonatomic) NSString *documentsDirectoryPath;

@property(retain, nonatomic) UIViewController *presentedDetailsController;

@property(assign, nonatomic) NSInteger pagesLoaded;
@end

@implementation CollectionViewController

static float const safeOffsetY = 1500;
static NSString * const fileExtension = @"tmp";
static NSString * const reuseIdentifier = @"Cell";
static NSString * const requestUrlString = @"https://picsum.photos/v2/list";

#pragma mark - Lifecycle

- (id)init {
    self = [super init];
    if (self) {
        self.pagesLoaded = 0;
        self.dataModel = [NSMutableArray array];
        [self.dataModel addObject:[NSMutableArray array]];
        [self.dataModel addObject:[NSMutableArray array]];
        
        self.customQueue = [[[NSOperationQueue alloc] init] autorelease];
        self.customQueue.maxConcurrentOperationCount = 1;
        self.customQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        
        self.documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.title = @"Imaginator";
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    
    [_dataModel release];
    [_customQueue release];
    [_documentsDirectoryPath release];
}

- (void)loadView {
    [super loadView];
    
    [self extendCollectionViewData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionViewLayout = [[[CollectionViewLayout alloc] init] autorelease];
    [self.collectionViewLayout updateDataModel:self.dataModel];
    
    self.collectionView = [[[UICollectionView alloc] initWithFrame:self.view.bounds
                                              collectionViewLayout:self.collectionViewLayout] autorelease];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.backgroundColor = [Colors getRandomColor];
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [self.view addSubview:self.collectionView];
    
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
                                              [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
                                              [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
                                              [self.collectionView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
                                              [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
                                              ]];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.dataModel count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataModel[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [Colors getRandomColor];
    
    NSDictionary *imageInfo = self.dataModel[indexPath.section][indexPath.item];
    UIImage *image = [imageInfo objectForKey:@"image"];
    
    if ([image isKindOfClass:[UIImage class]]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
        imageView.image = image;
        [cell addSubview:imageView];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSString *urlString = [imageInfo objectForKey:@"download_url"];
            NSString *fileId = [imageInfo objectForKey:@"id"];
            NSURL *url = [NSURL URLWithString:urlString];
            
            NSString *filePath = [NSString stringWithFormat:@"%@/%@.%@", self.documentsDirectoryPath, fileId, fileExtension];
            
            void(^drawImage)(NSData *) = ^void(NSData *data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithData:data];
                    [imageInfo setValue:image forKey:@"image"];

                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
                    imageView.image = image;
                    
                    [cell addSubview:imageView];
                });
            };
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSURL *url = [NSURL fileURLWithPath:filePath];
                NSData *data = [NSData dataWithContentsOfURL:url];
                drawImage(data);
            } else {
                [self uploadImageAtURL:url withFileId:fileId completion:^(NSData *data) {
                    drawImage(data);
                }];
            }
        });

    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *imageInfo = self.dataModel[indexPath.section][indexPath.item];
    UIImage *image = [imageInfo objectForKey:@"image"];
    
    DetailsViewController *detailsVC = [[DetailsViewController alloc] initWithImage:image];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDetailsViewSwipe:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    
    [detailsVC.view addGestureRecognizer:swipeGesture];
    
    detailsVC.modalPresentationStyle = UIModalPresentationPopover;
    [[Controllers getRootVC] presentViewController:detailsVC animated:YES completion:nil];
}

- (void)handleDetailsViewSwipe:(UISwipeGestureRecognizer *)swipeGesture {
    UIViewController *topVC = [Controllers getRootVC];
    
    [topVC dismissViewControllerAnimated:topVC completion:^{
        [_presentedDetailsController release];
        _presentedDetailsController = nil;
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    CGSize contentSize = [self.collectionViewLayout collectionViewContentSize];
    
    if (contentSize.height < (targetContentOffset->y + safeOffsetY)) {
        [self extendCollectionViewData];
    }
}

- (void)extendCollectionViewData {
    [self.customQueue addOperationWithBlock:^{
        [self.customQueue setSuspended:YES];
        
        NSURLComponents *components = [NSURLComponents componentsWithString:requestUrlString];
        components.queryItems = @[
              [NSURLQueryItem queryItemWithName:@"limit" value:[@(50) stringValue]],
              [NSURLQueryItem queryItemWithName:@"page" value:[@(self.pagesLoaded + 1) stringValue]],
        ];
        
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:components.URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            
            if (httpResponse.statusCode != 200) {
                NSLog(@"Response status code: %ld", httpResponse.statusCode);
                return;
            }
            
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                return;
            }
            
            NSError *parsingError = nil;
            
            NSArray *pictures = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parsingError];
            
            if (parsingError) {
                NSLog(@"Error parsin JSON: %@", parsingError.localizedDescription);
                return;
            }
            
            NSMutableArray *dataModelCopy = [self.dataModel copy];
            
            for (int i = 0; i < [pictures count]; i++) {
                NSInteger section = i % [self.dataModel count];
                [dataModelCopy[section] addObject:[pictures[i] mutableCopy]];
            }
            
            self.dataModel = dataModelCopy;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.pagesLoaded += 1;
                [self.collectionView reloadData];
                [self.collectionViewLayout invalidateLayout];
                [self.collectionViewLayout updateDataModel:self.dataModel];
                
                [self.customQueue setSuspended:NO];
            });
        }];
        
        [task resume];
    }];
}

#pragma mark - Utils

- (void)uploadImageAtURL:(NSURL *)url withFileId:(NSString *)fileId completion:(void(^)(NSData *))completionHandler {
    NSURLSessionTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if (httpResponse.statusCode != 200) {
            NSLog(@"Response status code: %ld", httpResponse.statusCode);
            return;
        }

        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            return;
        }
        
        NSString *newPath = [NSString stringWithFormat:@"%@/%@.%@", self.documentsDirectoryPath, fileId, fileExtension];
        NSURL *newLocation = [NSURL fileURLWithPath:newPath];
        
        NSError *moveError = nil;
        BOOL isFileMoved = [[NSFileManager defaultManager] moveItemAtURL:location
                                                                   toURL:newLocation
                                                                   error:&moveError];
        
        NSData *data = nil;
        
        if (!isFileMoved) {
            data = [NSData dataWithContentsOfURL:location];
            NSLog(@"Move file error: %@", moveError);
        } else {
            data = [NSData dataWithContentsOfURL:newLocation];
        }
        
        completionHandler(data);
    }];
    
    [task resume];
}

@end
