//
//  OfflineViewController.m
//  wPinpinbox
//
//  Created by Angus on 2016/5/31.
//  Copyright © 2016年 Angus. All rights reserved.
//

#import "OfflineViewController.h"
#import "CalbumlistCollectionViewCell.h"
#import "JCCollectionViewWaterfallLayout.h"
#import "wTools.h"
#import "boxAPI.h"
#import "AppDelegate.h"
#import "AsyncImageView.h"
#import "Remind.h"
#import "GlobalVars.h"

@interface OfflineViewController ()<CalbumlistDelegate>
{
    NSInteger type;
    NSMutableArray *dataarr;
    
    BOOL isLoading;
    NSInteger nextId;
    BOOL isreload;
    UIView *backview;
}

@property (nonatomic, strong) JCCollectionViewWaterfallLayout *layout;

@end

@implementation OfflineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    wtitle.text=NSLocalizedString(@"GeneralText-fav", @"");
    dataarr=[NSMutableArray new];
    nextId = 0;
    isLoading = NO;
    isreload=NO;
    type=1;
    
    _btn1.selected=NO;
    _btn2.selected=YES;
    _btn3.selected=NO;
    
    self.layout = (JCCollectionViewWaterfallLayout *)self.collectioview.collectionViewLayout;
    self.layout.headerHeight = 0.0f;
    self.layout.footerHeight = 0.0f;
    //self.layout.sectionInset=UIEdgeInsetsMake(0, 25, 0, 25);
    
    // Do any additional setup after loading the view from its nib.
    _collectioview.alwaysBounceVertical=YES;
    
    [_btn1 setTitle:NSLocalizedString(@"FavText-myWorks", @"") forState:UIControlStateNormal];
    [_btn2 setTitle:NSLocalizedString(@"FavText-otherFav", @"") forState:UIControlStateNormal];
    [_btn3 setTitle:NSLocalizedString(@"FavText-publicFav", @"") forState:UIControlStateNormal];
    
    [self reloaddata];
}

-(void) refresh{
    if (!isreload) {
        isreload=YES;
        
        nextId = 0;
        isLoading = NO;
        
        [self reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
//    AppDelegate *app=[[UIApplication sharedApplication]delegate];
    //[app.menu showMenu];
}

- (IBAction)btn:(UIButton *)sender {
    _btn1.selected=NO;
    _btn2.selected=YES;
    _btn3.selected=NO;
    
    
    if (sender!=_btn2) {
        Remind *rv=[[Remind alloc]initWithFrame:self.view.bounds];
        [rv addtitletext:@"目前為離線模式。"];
        [rv addBackTouch];
        [rv showView:self.view];
    }
    
    //[self reloaddata];
}

-(void)reloaddata {
    
    //[mytableview setContentOffset:CGPointZero animated:YES];
    
    if (!isLoading) {
        isLoading = YES;
        
        dataarr=[NSMutableArray new];
       
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *fileList=[fileManager contentsOfDirectoryAtPath:filepinpinboxDest error:nil];
        
        for (NSString *name in fileList) {
             NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/info.txt",name]];
            
            //檢查info是否存在
            if ([fileManager fileExistsAtPath:docDirectoryPath]) {
                
                NSString *str=[NSString stringWithContentsOfFile:docDirectoryPath encoding:NSUTF8StringEncoding error:nil];
                NSDictionary *dic= (NSDictionary *)[NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableContainers error:nil];
                NSMutableDictionary *data=[NSMutableDictionary new];
                
                [data setObject:dic[@"albumid"] forKey:@"album_id"];
                [data setObject:[NSString stringWithFormat:@"%@/%@/0.jpg",filepinpinboxDest,name] forKey:@"cover"];
                [data setObject:dic[@"description"] forKey:@"description"];
                [data setObject:dic[@"inserttime"] forKey:@"insertdate"];
                [data setObject:[NSNumber numberWithInt:0] forKey:@"user_id"];
                [data setObject:dic[@"author"] forKey:@"name"];
                [dataarr addObject:data];
            }
        }
        
        [_collectioview reloadData];
        isLoading=NO;
    }
}


//沒有資料產生的畫面


#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    if (backview!=nil) {
        [backview removeFromSuperview];
        backview=nil;
    }
    if (dataarr.count==0) {
        
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"CalbumV%li",type+1] owner:self options:nil];
        backview  = [subviewArray objectAtIndex:0];
        [collectionView addSubview:backview];
        
        UILabel *lab1=[(UILabel *)backview viewWithTag:100];
        switch (type) {
            case 0:
                lab1.text=NSLocalizedString(@"FavText-tipCreateNow", @"");
                break;
            case 1:
                lab1.text=NSLocalizedString(@"FavText-tipFindFavProducts", @"");
                break;
            case 2:{
                lab1.text=NSLocalizedString(@"FavText-tipInvite", @"");
                UILabel *lab2=[(UILabel *)backview viewWithTag:200];
                lab2.text=NSLocalizedString(@"FavText-tipInvite2", @"");
            }
                
                break;
            default:
                break;
        }
        
        return 0;
        
    }
    return dataarr.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CalbumlistCollectionViewCell *Cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"Calbumlist" forIndexPath:indexPath];
    Cell.delegate=self;
    Cell.type=type;
    
    [Cell reloadmenu];
    
    NSDictionary *data=dataarr[indexPath.row];
    
    Cell.albumid=[data[@"album_id"] stringValue];
    AsyncImageView *img=(AsyncImageView*)Cell.imageView;
    img.backgroundColor=[UIColor blackColor];
    //img.image=[UIImage imageWithContentsOfFile:data[@"cover"]];
    
    Cell.zipped=YES;
    Cell.stopview.hidden=YES;
    
    Cell.mydate.text=data[@"insertdate"];
    
    
    NSString *myString=[NSString stringWithFormat:@"    %@",data[@"description"]];
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:11]};
    CGSize size = [myString boundingRectWithSize:CGSizeMake(111, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    
    UILabel *label=(UILabel *)[Cell.bgview viewWithTag:1111];
    if (label==nil) {
        label=[[UILabel alloc]initWithFrame:CGRectMake(8, 230, 111, 0)];
        label.font=[UIFont systemFontOfSize:11];
        label.textColor=[UIColor colorWithRed:(float)110/255 green:(float)110/255 blue:(float)110/255 alpha:1.0];
        label.tag=1111;
        label.numberOfLines=0;
        [Cell.bgview addSubview:label];
    }
    label.frame=CGRectMake(label.frame.origin.x, label.frame.origin.y, 111, size.height);
    label.text=myString;
    
    
    
    //個人資料
    
    Cell.userid=data[@"user_id"];
    img=Cell.picture;
    img.image=[UIImage imageNamed:@""];
    
    
    Cell.mytitle.text=data[@"name"];
    
    //取得資料ID
    NSString * name=[NSString stringWithFormat:@"%@%@",[wTools getUserID],[data[@"album_id"] stringValue]];
    NSString *docDirectoryPath = [filepinpinboxDest stringByAppendingPathComponent:name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //檢查資料夾是否存在
    if ([fileManager fileExistsAtPath:docDirectoryPath]) {
        Cell.downimage.image=[UIImage imageNamed:@"icon_download-already.png"];
    }else{
        Cell.downimage.image=[UIImage imageNamed:@"icon_download.png"];
    }
    
    return Cell;
    
}
-(void)reloadData{
    
    nextId = 0;
    isLoading = NO;
    [self reloaddata];
    // [_collectioview reloadData];
}
#pragma mark UICollectionViewFlowLayoutDelegate
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int i=0;
    //i=arc4random() % 50;
    NSDictionary *data=dataarr[indexPath.row];
    NSString *myString=[NSString stringWithFormat:@"    %@",data[@"description"]];
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:11]};
    CGSize size = [myString boundingRectWithSize:CGSizeMake(111, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    i=size.height;
    return CGSizeMake(128, 242+15+i);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
