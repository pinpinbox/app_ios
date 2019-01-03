//
//  EditNewAlbumViewController.m
//  PinpinboxShareExtension
//
//  Created by Antelis on 2018/12/28.
//  Copyright © 2018 Angus. All rights reserved.
//

#import "EditNewAlbumViewController.h"
#import "SwitchButtonView.h"
#import "UserAPI.h"

#pragma mark -
@interface CategoryCell : UICollectionViewCell
@property (nonatomic) IBOutlet UILabel *catLabel;
@end
@implementation CategoryCell
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.catLabel.backgroundColor = selected? [UIColor colorWithRed:0.617 green:0.617 blue:0.617 alpha:1.0]: [UIColor colorWithRed:0.906 green:0.906 blue:0.906 alpha:1.0];
}
@end
#pragma mark -
@interface CateHeader : UICollectionReusableView
@property(nonatomic) IBOutlet UILabel *headerText;
@end
@implementation CateHeader
@end
#pragma mark -
@interface CategoryListLayout : UICollectionViewLayout
@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat space;
@end
@implementation CategoryListLayout

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    _itemSize = CGSizeMake(112, 48);
    _space = 8;
    return self;
}
- (NSInteger) findMaxItemInRow {
    NSInteger rows = [self.collectionView numberOfSections];
    NSInteger items = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < rows ; i++) {
        NSInteger t = [self.collectionView numberOfItemsInSection:i];
        if (t > items)
            items = t;
    }
    
    return items;
}
-(CGSize)collectionViewContentSize {
    NSInteger xSize = [self findMaxItemInRow] * (_itemSize.width + _space); // "space" is for spacing between cells.
    NSInteger ySize = [self.collectionView numberOfSections] * (_itemSize.height);
    return CGSizeMake(xSize, ySize);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:path];
    attributes.size = _itemSize;//CGSizeMake(itemWidth,itemHeight);
    long xValue = _itemSize.width/2 + path.row * (_itemSize.width + _space);
    long yValue = _itemSize.height/2 + path.section * (_itemSize.height);
    attributes.center = CGPointMake(xValue, yValue);
    return attributes;
}

- (BOOL)checkValidSection:(NSInteger )section item:(NSInteger)item {
    NSInteger rows = [self.collectionView numberOfSections];
    if (section < rows) {
        NSInteger items = [self.collectionView numberOfItemsInSection:section];
        return (item < items);
    }
    return NO;
}
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
    attributes.size = CGSizeZero;
    
    return attributes;
}
-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSInteger minRow =  (rect.origin.x > 0)?  rect.origin.x/(_itemSize.width + _space) : 0; // need to check because bounce gives negative values  for x.
    NSInteger maxRow = rect.size.width/(_itemSize.width + _space) + minRow;
    NSMutableArray* attributes = [NSMutableArray array];
    for(NSInteger i=0 ; i < self.collectionView.numberOfSections; i++) {
        for (NSInteger j=minRow ; j < maxRow; j++) {
            if ([self checkValidSection:i item:j]) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForItem:j inSection:i];
                [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
            }
        }
    }
    return attributes;
}
@end

#pragma mark -
@interface EditNewAlbumViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>
@property (nonatomic) IBOutlet UICollectionView *mainCate;
@property (nonatomic) IBOutlet UICollectionView *subCate;
@property (nonatomic) IBOutlet UISwitch *visSwitch;
@property (nonatomic) NSMutableDictionary *categoryData;
@property (nonatomic) NSMutableDictionary *metaData;
@property (nonatomic) NSMutableArray *mainCategory;

@property (nonatomic) NSInteger picked;
@property (nonatomic) NSInteger subpicked;

@property (nonatomic) IBOutlet UITextField *albumName;
@property (nonatomic) IBOutlet UITextField *albumDesc;
@property (nonatomic) IBOutlet UITextField *albumPoint;
@end

@implementation EditNewAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadMetadata];
}- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return YES;
}
- (IBAction)cancelAndDismiss:(id)sender {
    //[self.navigationController pop ]
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)loadMetaDataWithResult : (NSDictionary *)data {
    
    self.metaData = [NSMutableDictionary dictionaryWithDictionary:data];
    NSArray *list = data[@"firstpaging"];
    NSArray *l2 = [list sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *d1 = (NSDictionary *)obj1;
        NSDictionary *d2 = (NSDictionary *)obj2;
        int i1 = [d1[@"id"] intValue];
        int i2 = [d2[@"id"] intValue];
        
        if (i1 == i2) return NSOrderedSame;
        if (i1 < i2 ) return NSOrderedAscending;
        
        return NSOrderedDescending;
    }];
    for (NSDictionary *d in l2) {
        
        [self.categoryData setObject:d forKey:d[@"name"]];
        [self.mainCategory addObject:d[@"name"]];
    }
    
    [self.mainCate reloadData];
    [self.subCate reloadData];
    
    self.visSwitch.on = YES;
    [self visibilitySwitch:self.visSwitch];
}

- (void)loadMetadata {
    [self visibilitySwitch:self.visSwitch];
    self.categoryData = [NSMutableDictionary dictionary];
    self.mainCategory = [NSMutableArray array];
    self.picked = 0;
    self.subpicked = -1;
    __block typeof(self) wself = self;
    [UserAPI getAlbumSettingOptionsWithCompletionBlock:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself loadMetaDataWithResult:result];
            });
        } 
    }];
}
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CategoryCell *cell = (CategoryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"catCell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[CategoryCell alloc] init];
    }
    cell.catLabel.text = @"";
    if (collectionView == self.mainCate) {
        cell.catLabel.text = self.mainCategory[indexPath.item];
    } else {
        NSDictionary *data = self.categoryData[self.mainCategory[_picked]];
        NSArray *items = data[@"secondpaging"];
        if (indexPath.item < items.count)
            cell.catLabel.text = items[indexPath.item][@"name"];
    }
    return cell;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.mainCate) {
        return self.mainCategory.count;
    } else {
        if (self.mainCategory.count > 0 && _picked < self.mainCategory.count) {
            NSString *key = self.mainCategory[self.picked];
            NSDictionary *data = self.categoryData[key];
            NSArray *items = data[@"secondpaging"];
            return items? items.count: 0;
        }
    }
    return 0;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.mainCate) {
        self.picked = indexPath.item;
        [self.subCate reloadData];
    } else {
        self.subpicked = indexPath.item;
    }
}
- (IBAction)visibilitySwitch:(id)sender {
    UISwitch *s = (UISwitch *)sender;
    if (s) {
        NSArray *allViews = [self.view subviews];
        [allViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIView *v = (UIView *)obj;
            if (v.tag == 2222) {
                v.hidden = !s.on;
            }
        }];
    }
}
- (NSDictionary *)getAlbumSettings {
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    NSString *n = self.albumName.text;
    NSString *d = self.albumDesc.text;
    NSString *p = self.albumPoint.text;
    
    if ([p intValue] > 3) {
        [setting setObject:[NSNumber numberWithInt:[p intValue]] forKey:@"point"];
    }
    [setting setObject:n forKey:@"name"];
    if (d.length > 0)
        [setting setObject:d forKey:@"description"];
    
    NSDictionary *data = self.categoryData[self.mainCategory[_picked]];
    NSArray *items = data[@"secondpaging"];
    if (_subpicked < items.count)
        [setting setObject:items[_subpicked][@"id"] forKey:@"category_id"];
    else
        [setting setObject:items[0][@"id"] forKey:@"category_id"];
    
    [setting setObject:data[@"id"] forKey:@"categoryarea_id"];
    
    [setting setObject:((self.visSwitch.on)?@"open":@"close") forKey:@"act"];

    return setting;
}
- (IBAction)submitInsertNewAlbum:(id)sender {
    //  validation
    if (self.visSwitch.on) {
        
        if (self.albumName.text.length < 1 || self.subpicked < 0 || self.picked < 0) {
            return;
        }
    }
    NSDictionary *setting = [self getAlbumSettings];
    __block typeof(self) wself = self;
    [UserAPI insertNewAlbumWithSettings:setting CompletionBlock:^(NSDictionary * _Nonnull result, NSError * _Nonnull error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself didInsertAlbum];
            });
        } else {
            
        }
    }];
}
- (void)didInsertAlbum {
    if (self.settingDelegate)
        [self.settingDelegate reloadAlbumList];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
