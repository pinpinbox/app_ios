//
//  NewAlbumsViewController.m
//  wPinpinbox
//
//  Created by Angus on 2015/8/11.
//  Copyright (c) 2015年 Angus. All rights reserved.
//

#import "NewAlbumsViewController.h"
#import "ShowImageViewController.h"
@interface NewAlbumsViewController ()<UIScrollViewDelegate>
{
    NSMutableDictionary *dataDic;
    __weak IBOutlet UIView *bgview;
}
@end

@implementation NewAlbumsViewController
- (IBAction)toimage:(id)sender {
    
    
}


//產生對應位置的圖片
-(UIImage *)imageByCropping:(UIImageView *)imageViewToCrop todrag:(O_drag *)dragview{
  
    
    UIImage *inImage=imageViewToCrop.image;
    CGSize rotatedSize = CGSizeMake(dragview.bounds.size.width, dragview.bounds.size.height);
    //rotatedSize=dragview.frame.size;
    NSLog(@"%f",dragview.imagescale);
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    //位置
    CGContextTranslateCTM(bitmap, imageViewToCrop.frame.origin.x,imageViewToCrop.frame.origin.y);
    
    //大小倍率
    CGContextScaleCTM(bitmap, dragview.imagescale, dragview.imagescale);
    //角度
    CGContextRotateCTM(bitmap, dragview.imagerotate);
    
    
    
    [inImage drawInRect:CGRectMake(0,0,inImage.size.width,inImage.size.height)];
    //CGContextDrawImage(bitmap,CGRectMake(0,0,inImage.size.width*4,inImage.size.height*4),inImage.CGImage);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return resultImage;
}


- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *image=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, bgview.frame.size.width, bgview.frame.size.height)];
    image.image=[UIImage imageNamed:@"pinpin frame-28.png"];
    [bgview addSubview:image];
    
    
    dataDic =[[NSMutableDictionary alloc]init];
    
    // Do any additional setup after loading the view.
    //全版 1336  2004
    NSMutableDictionary *dic27_1=[[NSMutableDictionary alloc]init];
    [dic27_1 setValue:[NSNumber numberWithFloat:1336] forKey:@"w"];
    [dic27_1 setValue:[NSNumber numberWithFloat:595] forKey:@"h"];
    [dic27_1 setValue:[NSNumber numberWithFloat:53] forKey:@"y"];
    [dic27_1 setValue:[NSNumber numberWithFloat:0] forKey:@"x"];
    
    NSMutableDictionary *dic27_2=[[NSMutableDictionary alloc]init];
    [dic27_2 setValue:[NSNumber numberWithFloat:1336] forKey:@"w"];
    [dic27_2 setValue:[NSNumber numberWithFloat:1309] forKey:@"h"];
    [dic27_2 setValue:[NSNumber numberWithFloat:697] forKey:@"y"];
    [dic27_2 setValue:[NSNumber numberWithFloat:0] forKey:@"x"];

    NSArray *arr27=[NSArray arrayWithObjects:dic27_1,dic27_2, nil];
    [dataDic setValue:[arr27 copy] forKey:@"27"];
    
    
    
    NSMutableDictionary *dic28_1=[[NSMutableDictionary alloc]init];
    [dic28_1 setValue:@"1235" forKey:@"w"];
    [dic28_1 setValue:@"513" forKey:@"h"];
    [dic28_1 setValue:@"50" forKey:@"y"];
    [dic28_1 setValue:@"50" forKey:@"x"];
    
    NSMutableDictionary *dic28_2=[[NSMutableDictionary alloc]init];
    [dic28_2 setValue:@"480" forKey:@"w"];
    [dic28_2 setValue:@"1344" forKey:@"h"];
    [dic28_2 setValue:@"613" forKey:@"y"];
    [dic28_2 setValue:@"50" forKey:@"x"];
    
    NSMutableDictionary *dic28_3=[[NSMutableDictionary alloc]init];
    [dic28_3 setValue:@"712" forKey:@"w"];
    [dic28_3 setValue:@"630" forKey:@"h"];
    [dic28_3 setValue:@"613" forKey:@"y"];
    [dic28_3 setValue:@"574" forKey:@"x"];
    
    NSMutableDictionary *dic28_4=[[NSMutableDictionary alloc]init];
    [dic28_4 setValue:@"712" forKey:@"w"];
    [dic28_4 setValue:@"660" forKey:@"h"];
    [dic28_4 setValue:@"1294" forKey:@"y"];
    [dic28_4 setValue:@"574" forKey:@"x"];
    
    NSArray *arr28=[NSArray arrayWithObjects:dic28_1,dic28_2,dic28_3,dic28_4, nil];
    [dataDic setValue:[arr28 copy] forKey:@"28"];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[bgview subviews]count]>1) {
        return;
    }
    int i=0;
    for (NSDictionary *vdic in [dataDic objectForKey:@"28"]) {
        i++;
        float x =[[vdic objectForKey:@"x"]floatValue]/4;
        float y =[[vdic objectForKey:@"y"]floatValue]/4;
        float w =[[vdic objectForKey:@"w"]floatValue]/4;
        float h =[[vdic objectForKey:@"h"]floatValue]/4;
        
      /*
        DragImageScrollView *disv=[[DragImageScrollView alloc]initWithFrame:CGRectMake(x, y, w, h)];
        disv.tag=100+i;
        [disv setImage:[UIImage imageNamed:[NSString stringWithFormat:@"test%i.jpg",i]]];
        [bgview addSubview:disv];
       */
      
        O_drag *v=[[O_drag alloc]initWithFrame:CGRectMake(x, y, w, h)];
        v.tag=100+i;
        [v setImage:[UIImage imageNamed:[NSString stringWithFormat:@"test%i.jpg",i]]];
        [bgview addSubview:v];
      
        /*
        UIScrollView * sv=[[UIScrollView alloc]initWithFrame:CGRectMake(x, y, w, h)];
        sv.backgroundColor=[UIColor whiteColor];
        sv.tag=1000+i;
        sv.maximumZoomScale=3.0;
        sv.minimumZoomScale=0.5;
        sv.delegate=self;
        
        
        UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"test%i.jpg",i]]];
        [sv addSubview:img];
        
        float sw=w/img.frame.size.width;
        float sh=h/img.frame.size.height;
        if (sw>sh) {
            sv.minimumZoomScale=sw;
        }else{
            sv.minimumZoomScale=sh;
        }
        
        
        sv.contentSize=CGSizeMake(img.frame.size.width, img.frame.size.height);
        
        [bgview addSubview:sv];
         */
        
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return  [[scrollView subviews]objectAtIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier]isEqualToString:@"showimage"]) {
        
        
        int i =0;
        NSMutableArray*arr=[[NSMutableArray alloc]init];
        for (NSDictionary *vdic in [dataDic objectForKey:@"28"]) {
            i++;
            O_drag *v=(O_drag*)[bgview viewWithTag:100+i];
            UIImage*img=[v finishCropping];
            
            NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
            [dic setObject:img forKey:@"img"];
            [dic setObject:v.imageView forKey:@"frame"];
            [arr addObject:dic];
        }
        UIImage *image=[self compositeImage:arr];
        
        ShowImageViewController *v=segue.destinationViewController;
        v.showimg=image;;
        
    }
}

-(UIImage *)compositeImage:(NSArray *)array{
    //UIImage *image=nil;
    UIImage *bgimag=[UIImage imageNamed:@"pinpin frame-28.png"];
    UIGraphicsBeginImageContext(bgimag.size);
    int i=0;
    [bgimag drawInRect:CGRectMake( 0.0f, 0.0f, bgimag.size.width, bgimag.size.height)];
    for (NSDictionary *vdic in [dataDic objectForKey:@"28"]) {
        UIImage *setimg=[[array objectAtIndex:i]objectForKey:@"img"];
        UIImageView *imgv=[[array objectAtIndex:i]objectForKey:@"frame"];
        CGRect frame=imgv.frame;
        i++;
        float x =[[vdic objectForKey:@"x"]floatValue];
        float y =[[vdic objectForKey:@"y"]floatValue];
        float w =[[vdic objectForKey:@"w"]floatValue];
        float h =[[vdic objectForKey:@"h"]floatValue];
        CGRect f;
        if (imgv.frame.size.height>h/4 && imgv.frame.size.width>w/4) {
            f=CGRectMake(x, y, w, h);
        }else {
            
            if (frame.size.width*4 >w) {
                 f=CGRectMake(x, y+frame.origin.y*4, w, frame.size.height*4);
            }else if (frame.size.height*4 >h){
                f=CGRectMake(x+frame.origin.x*4, y, frame.size.width*4, h);
            }else{
                f=CGRectMake(x+frame.origin.x*4, y+frame.origin.y*4, frame.size.width*4, frame.size.height*4);
            }
            
            
        }
           [setimg drawInRect:f];
    }
    // 現在のグラフィックスコンテキストの画像を取得する
    bgimag = UIGraphicsGetImageFromCurrentImageContext();
    
    // 現在のグラフィックスコンテキストへの編集を終了
    // (スタックの先頭から削除する)
    UIGraphicsEndImageContext();
    
    return bgimag;
}


#pragma mark - dragdelegate
-(void)selectPhoto:(O_drag *)drag{
    //紀錄目前選擇框框
    selectdrag=drag;
    //互叫照相機
    
}

@end
