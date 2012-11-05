//
//  ZYViewController.m
//  BoYuEducation
//
//  Created by Wei on 12-10-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ZYViewController.h"
#import "RBFilePreviewer.h"

@interface ZYViewController ()

@end

@implementation ZYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"load example view, frame: %@", NSStringFromCGRect(self.view.frame));
    _skinId = 0;
    
    UIView *logoView = [[UIView alloc]initWithFrame:CGRectMake(25, 15, 164, 60)];
    UIImage *logoImage = [UIImage imageNamed:@"logo.png"];
    logoView.backgroundColor = [UIColor colorWithPatternImage:logoImage];
    [self.view addSubview:logoView];
    [logoView release];
    
    [self changeSkinId:_skinId];
    
    _menuView = [[ZYMenuView alloc]init];
    _menuView.delegate = self;
    [self.view addSubview:_menuView];
    
    [self initBackView];
    //初始化centerView
    _centerView = [[ZYCenterView alloc]initWithMenuCellIndex:0];
    //添加拖动手势
    [_centerView addPanGesture];
    _centerView.delegate = self;
    [self.view addSubview:_centerView];
    
    return;
}

- (void)initRightViewWithView: (UIView *)view
{
    if (_rightViewController == nil) {
        _rightViewController = [[ZYRightViewController alloc]init];
    }
    _rightViewController.delegate = self;
    
//    [_rightViewController putOut];
    
    _rightViewController.putInFrame = view.frame;
    _rightViewController.view = view;
    
    [_rightViewController.view setFrame:CGRectMake(1524, view.frame.origin.y, view.frame.size.width, view.frame.size.height)];
    [_rightViewController addPanGesture];
    
    [self.view addSubview:_rightViewController.view];
//    [_rightViewController putIn];
}

//初始化backView
- (void)initBackView
{
    _backView = [[UIView alloc]initWithFrame:CGRectMake((BY_MENUVIEW_MARGIN_LEFT + BY_MENUCELL_WIDTH + BY_CENTERVIEW_WIDTH - BY_CENTERVIEW_OVER_LENGHT), 0, (1024 - BY_MENUVIEW_MARGIN_LEFT - BY_MENUCELL_WIDTH - BY_CENTERVIEW_WIDTH + BY_CENTERVIEW_OVER_LENGHT), 748)];
    _backView.exclusiveTouch = YES;
    
    NSMutableArray *appViewsArray = [[NSMutableArray alloc]init];
    
    UIImage *image_1 = [[UIImage imageNamed:@"button_01.png"]autorelease];
    ZYAppView *appView_1 = [[ZYAppView alloc]initWithImage:image_1 Name:@"营销工具"];
    [appViewsArray addObject:appView_1];
    [appView_1 release];
    
    UIImage *image_2 = [[UIImage imageNamed:@"button_02.png"]autorelease];
    ZYAppView *appView_2 = [[ZYAppView alloc]initWithImage:image_2 Name:@"金融产品"];
    [appViewsArray addObject:appView_2];
    [appView_2 release];
    
    UIImage *image_3 = [[UIImage imageNamed:@"button_03.png"]autorelease];
    ZYAppView *appView_3 = [[ZYAppView alloc]initWithImage:image_3 Name:@"计算器"];
    [appViewsArray addObject:appView_3];
    [appView_3 release];
    
    UIImage *image_4 = [[UIImage imageNamed:@"button_04.png"]autorelease];
    ZYAppView *appView_4 = [[ZYAppView alloc]initWithImage:image_4 Name:@"更换皮肤"];
    [appViewsArray addObject:appView_4];
    [appView_4 release];
    
    UIImage *image_5 = [[UIImage imageNamed:@"button_plus.png"]autorelease];
    ZYAppView *appView_5 = [[ZYAppView alloc]initWithImage:image_5 Name:@""];
    [appViewsArray addObject:appView_5];
    [appView_5 release];
    
    _gridView = [[ZYGridView alloc]initWithZYAppViews:appViewsArray];
    [appViewsArray release];
    _gridView.delegate = self;
    _gridView.exclusiveTouch = YES;
    
    //水平对齐
    CGRect backViewFrame = _backView.frame;
    CGRect gridViewFrame = _gridView.frame;
    gridViewFrame = CGRectMake(((backViewFrame.size.width - gridViewFrame.size.width) / 2), gridViewFrame.origin.y, gridViewFrame.size.width, gridViewFrame.size.height);
    [_gridView setFrame:gridViewFrame];
    
    //向右滑动关闭窗口
    UIImage *closeImage = [UIImage imageNamed:@"close.png"];
    UIView *hintImageView = [[UIView alloc]initWithFrame:CGRectMake(40, 450, closeImage.size.width, closeImage.size.height)];
    hintImageView.backgroundColor = [UIColor colorWithPatternImage:closeImage];
    [_gridView addSubview:hintImageView];
    [hintImageView release];
    
    [_backView addSubview:_gridView];
    [self.view addSubview:_backView];
}

//backView适配动画
- (void)doBackViewAnimationWithRecognizerDirection: (UISwipeGestureRecognizerDirection)recognizerDirection
{
    CGRect centerViewFrame = _centerView.frame;
    CGRect backViewFrame = _backView.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    if (recognizerDirection == UISwipeGestureRecognizerDirectionLeft && _gridView.isInitStatic == YES) {
        backViewFrame = CGRectMake((centerViewFrame.origin.x + centerViewFrame.size.width), backViewFrame.origin.y, backViewFrame.size.width + BY_CENTERVIEW_MOVE_LENGHT, backViewFrame.size.height);
        _gridView.isInitStatic = NO;
    } else if (recognizerDirection == UISwipeGestureRecognizerDirectionRight && _gridView.isInitStatic == NO) {
        backViewFrame = CGRectMake((centerViewFrame.origin.x + centerViewFrame.size.width), backViewFrame.origin.y, backViewFrame.size.width - BY_CENTERVIEW_MOVE_LENGHT, backViewFrame.size.height);
        _gridView.isInitStatic = YES;
    }
    
    [_backView setFrame:backViewFrame];
    [UIView commitAnimations];
    NSLog(@"move backView.");
    
    //水平对齐gridView
    CGRect gridViewFrame = _gridView.frame;
    gridViewFrame = CGRectMake(((backViewFrame.size.width - gridViewFrame.size.width) / 2), gridViewFrame.origin.y, gridViewFrame.size.width, gridViewFrame.size.height);
    
    //动画开始
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [_gridView setFrame:gridViewFrame];
    [UIView commitAnimations];
    
}

- (void)didMoveCenterViewToDirection:(NSString *)direction
{
    if ([direction isEqualToString:@"left"]) {
        [self doBackViewAnimationWithRecognizerDirection:UISwipeGestureRecognizerDirectionLeft];
    } else {
        [self doBackViewAnimationWithRecognizerDirection:UISwipeGestureRecognizerDirectionRight];
    }
}

- (void)centerTableView:(ZYCenterTableView *)centerTableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect rightViewFrame;
    UIView *headerView;
    UITableView *tableView;
    UIView *view = [[UIView alloc]init];
    
    if (_rightViewController == nil) {
        _rightViewController = [[ZYRightViewController alloc]init];
    }
    
    NSLog(@"ZYView press button section:%d, row:%d", indexPath.section, indexPath.row);
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(30, 300, 300, 100)];
    
    switch (_menuView.currentCellIndex) {
        case 0:
        {
//            label.text = [NSString stringWithFormat:@"菜单1 group：%d row:%d", indexPath.section, indexPath.row];
            rightViewFrame = CGRectMake((BY_MENUVIEW_MARGIN_LEFT + BY_MENUCELL_MARGIN_LEFT + BY_MENUCELL_WIDTH - BY_CENTERVIEW_OVER_LENGHT - BY_CENTERVIEW_MOVE_LENGHT + BY_CENTERVIEW_WIDTH - 10), 0, 470, 748);
            
            headerView = [_rightViewController getHeaderViewWithRightViewFrame:rightViewFrame MenuIndex:_menuView.currentCellIndex];
            tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, headerView.frame.size.height, rightViewFrame.size.width, (rightViewFrame.size.height - headerView.frame.size.height)) style:UITableViewStylePlain];
        }
            break;
            
        case 1:
        {
//            label.text = [NSString stringWithFormat:@"菜单2 group：%d row:%d", indexPath.section, indexPath.row];
            rightViewFrame = CGRectMake((BY_MENUVIEW_MARGIN_LEFT + BY_MENUCELL_MARGIN_LEFT + BY_MENUCELL_WIDTH - BY_CENTERVIEW_OVER_LENGHT - BY_CENTERVIEW_MOVE_LENGHT + 60), 0, 850, 748);
//            headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rightViewFrame.size.width, 60)];
//            headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"title_br.png"]];
            
            headerView = [_rightViewController getHeaderViewWithRightViewFrame:rightViewFrame MenuIndex:_menuView.currentCellIndex];
            tableView = [[UITableView alloc]initWithFrame:CGRectMake(15, (headerView.frame.size.height + 10), (rightViewFrame.size.width - 15 * 2), (rightViewFrame.size.height - headerView.frame.size.height - 100)) style:UITableViewStylePlain];
//            tableView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
            tableView.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
//            tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background02.png"]];
            
            UIButton *commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *image = [UIImage imageNamed:@"approval.png"];
            [commitButton setBackgroundImage:image forState:UIControlStateNormal];
            [commitButton setFrame:CGRectMake(((rightViewFrame.size.width - image.size.width) / 2), (rightViewFrame.size.height - 70), image.size.width, image.size.height)];
            [view addSubview:commitButton];
        }
            break;
            
        case 2:
        {
//            label.text = [NSString stringWithFormat:@"菜单3 group：%d row:%d", indexPath.section, indexPath.row];
            rightViewFrame = CGRectMake((BY_MENUVIEW_MARGIN_LEFT + BY_MENUCELL_MARGIN_LEFT + BY_MENUCELL_WIDTH - BY_CENTERVIEW_OVER_LENGHT - BY_CENTERVIEW_MOVE_LENGHT + BY_CENTERVIEW_WIDTH - 10), 0, 470, 748);
//            headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rightViewFrame.size.width, 60)];
//            headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"title_br.png"]];
            
            headerView = [_rightViewController getHeaderViewWithRightViewFrame:rightViewFrame MenuIndex:_menuView.currentCellIndex];
            tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, headerView.frame.size.height, rightViewFrame.size.width, (rightViewFrame.size.height - headerView.frame.size.height)) style:UITableViewStylePlain];
        }
            break;
            
            
        case 3:
        {
//            label.text = [NSString stringWithFormat:@"菜单4 group：%d row:%d", indexPath.section, indexPath.row];
            rightViewFrame = CGRectMake((BY_MENUVIEW_MARGIN_LEFT + BY_MENUCELL_MARGIN_LEFT + BY_MENUCELL_WIDTH - BY_CENTERVIEW_OVER_LENGHT - BY_CENTERVIEW_MOVE_LENGHT + 60), 0, 850, 748);
//            headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rightViewFrame.size.width, 60)];
//            headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"title_br.png"]];
            
            headerView = [_rightViewController getHeaderViewWithRightViewFrame:rightViewFrame MenuIndex:_menuView.currentCellIndex];
            tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, headerView.frame.size.height, rightViewFrame.size.width, (rightViewFrame.size.height - headerView.frame.size.height)) style:UITableViewStylePlain];
        }
            break;
            
        default:
            break;
    }
    
    [view setFrame:rightViewFrame];
    view.backgroundColor = [UIColor whiteColor];
    //设置圆角
    view.layer.cornerRadius = 6;
    view.layer.masksToBounds = YES;
    
    [view addSubview:headerView];
    
    if (_menuView.currentCellIndex == 0 || _menuView.currentCellIndex == 1) {
        tableView.delegate = self;
        tableView.dataSource = self;
        //去除cell分割线
        tableView.separatorStyle = NO;
        
        tableView.backgroundView = [[[UIView alloc]init]autorelease];
        tableView.backgroundView.backgroundColor = [UIColor clearColor];
        tableView.layer.cornerRadius = 6;
        tableView.layer.masksToBounds = YES;
        
        [view addSubview:tableView];
    } else if (_menuView.currentCellIndex == 2) {
        UIView *testView = [[UIView alloc]initWithFrame:CGRectMake(15, (headerView.frame.size.height + 10), (rightViewFrame.size.width - 15 * 2), (rightViewFrame.size.height - headerView.frame.size.height - 100))];
        testView.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
        testView.layer.cornerRadius = 6;
        testView.layer.masksToBounds = YES;
        
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 500, 50)];
        title.backgroundColor = [UIColor clearColor];
        title.text = @"1. 这里是考试题目这里是考试题目这里是考试题目？";
        title.font = [UIFont boldSystemFontOfSize:18];
        [testView addSubview:title];
        [title release];
        
        CGRect frame;
        
        frame = CGRectMake(40, 80, 600, 40);
        UILabel *option_A = [[UILabel alloc]init];
        option_A.backgroundColor = [UIColor clearColor];
        [option_A setFrame:frame];
        option_A.text = @"A. 这里是考题选项";
        [testView addSubview:option_A];
        [option_A release];
        
        frame.origin.y += 50;
        UILabel *option_B = [[UILabel alloc]init];
        option_B.backgroundColor = [UIColor clearColor];
        [option_B setFrame:frame];
        option_B.text = @"B. 这里是考题选项考题选项";
        [testView addSubview:option_B];
        [option_B release];
        
        frame.origin.y += 50;
        UILabel *option_C = [[UILabel alloc]init];
        option_C.backgroundColor = [UIColor clearColor];
        [option_C setFrame:frame];
        option_C.text = @"C. 这里是考题选项选项";
        [testView addSubview:option_C];
        [option_C release];
        
        frame.origin.y += 50;
        UILabel *option_D = [[UILabel alloc]init];
        option_D.backgroundColor = [UIColor clearColor];
        [option_D setFrame:frame];
        option_D.text = @"D. 这里是考题选项考题选项这里";
        [testView addSubview:option_D];
        [option_D release];
        
        [view addSubview:testView];
        [testView release];
        
        UIButton *commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"approval.png"];
        [commitButton setBackgroundImage:image forState:UIControlStateNormal];
        [commitButton setFrame:CGRectMake(((rightViewFrame.size.width - image.size.width) / 2), (rightViewFrame.size.height - 70), image.size.width, image.size.height)];
        [view addSubview:commitButton];
        
        
    } else if (_menuView.currentCellIndex == 3) {
        UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, headerView.frame.size.height, rightViewFrame.size.width, (rightViewFrame.size.height - headerView.frame.size.height))];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
        [webView loadRequest:request];
        webView.backgroundColor = [UIColor whiteColor];
        [view addSubview:webView];
        _rightViewController.webView = webView;     
        [webView release];
    }
    [tableView release];
    
//    [view addSubview:label];
//    [label release];
    
//    [headerView release];
    if (!(_rightViewController == nil)) {
        [_rightViewController putOutWithChecking:NO];
    }
    [self initRightViewWithView:view];
    
    
    [_rightViewController putIn];
    NSLog(@"count:%d", [_rightViewController.view subviews].count);
    [view release];
}

- (void)ZYRightViewPutIn
{
    _centerView.isLocked = YES;
}

- (void)ZYRightViewPutOut
{
    _centerView.isLocked = NO;
}

- (NSArray *)documentsAsURLs {
    NSArray *documents = [[NSArray alloc]initWithObjects:@"TaoBao客户端高性能高稳定性应用框架 .pdf", nil];
    
    NSMutableArray *urls = [NSMutableArray array];
    
    for (NSString *file in documents) {
        
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:file ofType:nil]];
        [urls addObject:url];
    }
    
    return urls;
}

- (void)pressFileCloseButton:sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)pressFileButton:sender
{
    RBFilePreviewer * previewer = [[RBFilePreviewer alloc] initWithFiles:[self documentsAsURLs]];
    [previewer setCurrentPreviewItemIndex:0];
    UIBarButtonItem * button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                             target:self
                                                                             action:@selector(pressFileCloseButton:)];
    [previewer setRightBarButtonItem:button];
    [button release];
    
    
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:previewer];
    
    [self presentModalViewController:navController animated:YES];
    [navController release];
    return;
    
    
    
//    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:self];
    
    UITableViewController *fileViewController = [[UITableViewController alloc]init];
    [[fileViewController navigationItem] setTitle:@"RBFilePreviewer"];
    [fileViewController.view setFrame:CGRectMake(100, 100, 824, 648)];
    [self.view addSubview:fileViewController.view];
    
    [[fileViewController navigationController] pushViewController:previewer animated:YES];
    
//    [fileView addSubview:navigationController.view];
    
//    [self.view addSubview:fileView];
    [previewer release];
//    [fileView release];
    [fileViewController release];
    NSLog(@"filefilefile");
}

//ZYAppView代理
- (void)pressButton:(NSString *)buttonName
{
    NSLog(@"press button %@", buttonName);
    if ([buttonName isEqualToString:@"更换皮肤"]) {
        [self pushBackgound];
//        [self changeSkinId:++_skinId];
    }
}

- (void)pushBackgound
{
    [[self.view viewWithTag:22] setHidden:![self.view viewWithTag:22].isHidden];
    if ([self.view viewWithTag:22] == nil) {
        UIButton *fullViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [fullViewButton setFrame:CGRectMake(0, 0, 1024, 748)];
        [fullViewButton setBackgroundColor:[UIColor clearColor]];
        fullViewButton.tag = 22;
        [fullViewButton addTarget:self action:@selector(pressBackgroundButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:fullViewButton];
    }
    
    UIView *bgMaskView;
    if (_backgroundMaskView == nil) {
        _backgroundMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 868, 1024, 140)];
        _backgroundMaskView.backgroundColor = [UIColor clearColor];
        _backgroundMaskView.tag = 0;
        
        
        bgMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _backgroundMaskView.frame.size.width, _backgroundMaskView.frame.size.height)];
        bgMaskView.tag = 33;
        bgMaskView.backgroundColor = [UIColor blackColor];
        bgMaskView.alpha = 0.0f;
        [_backgroundMaskView addSubview:bgMaskView];
        [self.view addSubview:_backgroundMaskView];
        
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 824, 140)];
        
        scrollView.directionalLockEnabled = YES;
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        [scrollView setContentSize:CGSizeMake(1024, 140)];
        [_backgroundMaskView addSubview:scrollView];
        
        UIImage *image;
        CGRect frame = CGRectMake(20, 10, 160, 120);
        
        image = [UIImage imageNamed:@"background_01.png"];
        UIButton *button_1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_1 setFrame:frame];
        button_1.layer.borderWidth = 3.f;
        button_1.layer.borderColor = [UIColor whiteColor].CGColor;
        button_1.tag = 0;
        [button_1 setBackgroundImage:image forState:UIControlStateNormal];
        [button_1 addTarget:self action:@selector(pressBackgroundButton:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button_1];
        
        image = [UIImage imageNamed:@"background_02.png"];
        UIButton *button_2 = [UIButton buttonWithType:UIButtonTypeCustom];
        frame.origin.x += 180;
        [button_2 setFrame:frame];
        button_2.layer.borderWidth = 3.f;
        button_2.layer.borderColor = [UIColor whiteColor].CGColor;
        button_2.tag = 1;
        [button_2 setBackgroundImage:image forState:UIControlStateNormal];
        [button_2 addTarget:self action:@selector(pressBackgroundButton:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button_2];
        
        image = [UIImage imageNamed:@"background_03.png"];
        UIButton *button_3 = [UIButton buttonWithType:UIButtonTypeCustom];
        frame.origin.x += 180;
        [button_3 setFrame:frame];
        button_3.layer.borderWidth = 3.f;
        button_3.layer.borderColor = [UIColor whiteColor].CGColor;
        button_3.tag = 2;
        [button_3 setBackgroundImage:image forState:UIControlStateNormal];
        [button_3 addTarget:self action:@selector(pressBackgroundButton:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button_3];
        
        image = [UIImage imageNamed:@"background_04.png"];
        UIButton *button_4 = [UIButton buttonWithType:UIButtonTypeCustom];
        frame.origin.x += 180;
        [button_4 setFrame:frame];
        button_4.layer.borderWidth = 3.f;
        button_4.layer.borderColor = [UIColor whiteColor].CGColor;
        button_4.tag = 3;
        [button_4 setBackgroundImage:image forState:UIControlStateNormal];
        [button_4 addTarget:self action:@selector(pressBackgroundButton:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button_4];
        
        image = [UIImage imageNamed:@"background_05.png"];
        UIButton *button_5 = [UIButton buttonWithType:UIButtonTypeCustom];
        frame.origin.x += 180;
        [button_5 setFrame:frame];
        button_5.layer.borderWidth = 3.f;
        button_5.layer.borderColor = [UIColor whiteColor].CGColor;
        button_5.tag = 4;
        [button_5 setBackgroundImage:image forState:UIControlStateNormal];
        [button_5 addTarget:self action:@selector(pressBackgroundButton:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button_5];
        
        image = [UIImage imageNamed:@"button_plus_big.png"];
        UIButton *button_add = [UIButton buttonWithType:UIButtonTypeCustom];
        frame.origin.x = scrollView.frame.origin.x + scrollView.frame.size.width + 20;
        [button_add setFrame:frame];
        button_add.tag = 999;
        [button_add setBackgroundImage:image forState:UIControlStateNormal];
        [button_add addTarget:self action:@selector(pressBackgroundButton:) forControlEvents:UIControlEventTouchUpInside];
        [_backgroundMaskView addSubview:button_add];
    } else {
        bgMaskView = [_backgroundMaskView viewWithTag:33];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
//    [bgMaskView setFrame:_backgroundMaskView.frame];
    
    
    
    // 准备动画
//    CATransition *animation = [CATransition animation];
//    //动画播放持续时间
//    [animation setDuration:0.5f];
//    //动画速度,何时快、慢
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
//    /*动画效果
//     kCATransitionFade      淡出
//     kCATransitionMoveIn    覆盖原图
//     kCATransitionPush      推出
//     kCATransitionReveal    底部显出来
//     */
//    [animation setType:kCATransitionPush];
//    [_backgroundMaskView.layer addAnimation:animation forKey:nil];
    
    //变更
    //    [self addSubview:tmpView];
    //    _backgroundMaskView.alpha = 0.4f;
    //tag为0，表示是隐藏状态，为1是显示状态。
    if (_backgroundMaskView.tag == 0) {
        bgMaskView.alpha = 0.4f;
        [_backgroundMaskView setFrame:CGRectMake(0, 468, 1024, 140)];
        _backgroundMaskView.tag = 1;
    } else {
        bgMaskView.alpha = 0.0f;
        [_backgroundMaskView setFrame:CGRectMake(0, 868, 1024, 140)];
        _backgroundMaskView.tag = 0;
    }
    
    // 结束动画
    [UIView commitAnimations];
}

- (void)pressBackgroundButton:sender
{
    UIButton *button = (UIButton *)sender;
    NSLog(@"btn.tag = %d", button.tag);
    if (button.tag == 22) {
//        [button removeFromSuperview];
        [self pushBackgound];
        return;
    } else if (button.tag == 999) {
        //弹出picker
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//        [self presentModalViewController:imagePickerController animated:YES];
        
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        [popoverController presentPopoverFromRect:CGRectMake(0, 0, 0, 0) inView:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        return;
    }
    [self changeSkinId:button.tag];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
}

//更换皮肤
- (void)changeSkinId: (NSInteger)skinId
{
    NSArray *skinNameArray = [[NSArray alloc]initWithObjects:
                              @"background_01.png", 
                              @"background_02.png", 
                              @"background_03.png", 
                              @"background_04.png", 
                              @"background_05.png", nil];
    
    // 准备动画
    CATransition *animation = [CATransition animation];
    //动画播放持续时间
    [animation setDuration:0.5f];
    //动画速度,何时快、慢
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [animation setType:kCATransitionFade];
    [self.view.layer addAnimation:animation forKey:nil];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[skinNameArray objectAtIndex:skinId]]];
    // 结束动画
    [UIView commitAnimations];
}

//menuView代理
- (void)didSelectMenuCellAtIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            NSLog(@"00000000000000");
        }
            break;
            
        case 1:
        {
            NSLog(@"11111111111111");
        }
            break;
            
        case 2:
        {
            NSLog(@"22222222222222");
        }
            break;
            
        default:
            break;
    }
    
    //切换centerView内容
    [_centerView changeContentViewWithMenuIndex:index];
    [_rightViewController putOutWithChecking:NO]; 
}

- (void)ZYMenuView:(UIView *)menuView PressSetupButton:(UIButton *)setupButton
{
    ZYSettingViewController *settingViewController = [[ZYSettingViewController alloc]init];
    
    [settingViewController.view setFrame:CGRectMake(0.f, 0.f, 600.f, 556.f)];
    
    settingViewController.modalPresentationStyle = UIModalPresentationFormSheet;//有三种状态，自己看看是哪种
    [self presentModalViewController:settingViewController animated:YES];
    settingViewController.view.superview.frame = CGRectMake(0.f, 0.f, 600.f, 600.f);//it's important to do this after 
    settingViewController.view.superview.center = CGPointMake(512, 384);
    
    return;
}
//////rightView tableView 代理
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
    }
    UIView *cellView = [cell viewWithTag:1];
    
    switch (_menuView.currentCellIndex) {
        case 0:
        {
            if (cellView != nil) {
                //按tag取view，改数据。
                return cell;
            } else {
                cellView = [[UIView alloc]initWithFrame:CGRectMake(15, 5, (tableView.frame.size.width - 15 * 2), (250 - 15 - 14))];
                cellView.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
                
                UIImage *shadowImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"background02_br" ofType:@"png"]];
                UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
                UIView *bottomShadowView = [[UIView alloc]initWithFrame:CGRectMake(15, (cellView.frame.origin.y + cellView.frame.size.height), cellView.frame.size.width, shadowImage.size.height)];
                [shadowImageView setFrame:CGRectMake(0, 0, bottomShadowView.frame.size.width, shadowImage.size.height)];
                [bottomShadowView addSubview:shadowImageView];
                [shadowImageView release];
                
                UIImage *image;
                UIImageView *imageView;
                UILabel *label;
                CGRect frame;
                
                //小人图标
                image = [UIImage imageNamed:@"head.png"];
                imageView = [[UIImageView alloc]initWithImage:image];
                frame = CGRectMake(25, 15, image.size.width, image.size.height);
                [imageView setFrame:frame];
                [cellView addSubview:imageView];
                [imageView release];
                
                //分割线
                image = [UIImage imageNamed:@"background02_line.png"];
                imageView = [[UIImageView alloc]initWithImage:image];
                frame = CGRectMake(15, 130, (cellView.frame.size.width - 15 * 2), image.size.height);
                [imageView setFrame:frame];
                [cellView addSubview:imageView];
                [imageView release];
                
                //文件背景蓝
                image = [UIImage imageNamed:@"file_br.png"];
                imageView = [[UIImageView alloc]initWithImage:image];
                frame = CGRectMake(20, 170, image.size.width, image.size.height);
                UIButton *fileButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [fileButton setBackgroundImage:image forState:UIControlStateNormal];
                [fileButton setFrame:frame];
                [fileButton addTarget:self action:@selector(pressFileButton:) forControlEvents:UIControlEventTouchUpInside];
//                [imageView setFrame:frame];
                [cellView addSubview:fileButton];
//                [imageView release];
                
                //姓名
                frame = CGRectMake(60, 15, 200, image.size.height);
                label = [[UILabel alloc]initWithFrame:frame];
                label.text = @"张建国";
                label.font = [UIFont boldSystemFontOfSize:18];
                label.textAlignment = UITextAlignmentLeft;
                label.backgroundColor = [UIColor clearColor];
                [cellView addSubview:label];
                [label release];
                
                //课程名
                frame = CGRectMake(25, 50, 350, image.size.height);
                label = [[UILabel alloc]initWithFrame:frame];
                label.text = @"金融理财概述和CFP制度";
                label.textAlignment = UITextAlignmentLeft;
                label.backgroundColor = [UIColor clearColor];
                [cellView addSubview:label];
                [label release];
                
                //课程时间
                frame = CGRectMake(25, 85, 350, image.size.height);
                label = [[UILabel alloc]initWithFrame:frame];
                label.text = @"09:15 ~ 10:00";
                label.textAlignment = UITextAlignmentLeft;
                label.backgroundColor = [UIColor clearColor];
                [cellView addSubview:label];
                [label release];
                
                //课程介绍
                frame = CGRectMake(25, 135, 350, image.size.height);
                label = [[UILabel alloc]initWithFrame:frame];
                label.text = @"课程介绍";
                label.textAlignment = UITextAlignmentLeft;
                label.backgroundColor = [UIColor clearColor];
                [cellView addSubview:label];
                [label release];
                
                //课件
                frame = CGRectMake(60, 168, image.size.width, image.size.height);
                label = [[UILabel alloc]initWithFrame:frame];
                label.text = @"金融理财概述和CFP制度.xls";
                label.textAlignment = UITextAlignmentLeft;
                label.backgroundColor = [UIColor clearColor];
                [cellView addSubview:label];
                [label release];
                
                cellView.layer.cornerRadius = 6;
                cellView.layer.masksToBounds = YES;
                cellView.tag = 1;
                [cell addSubview:cellView];
                [cell addSubview:bottomShadowView];
                [cellView release];
                [bottomShadowView release];
                
            }

        }
            break;
        //在线调查
        case 1:
        {
            if (cellView != nil) {
                //按tag取view，改数据。
                return cell;
            } else {
                UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(20, 20, 500, 30)];
                title.backgroundColor = [UIColor clearColor];
                title.text = @"1. 这里是调查问题这里是调查问题这里是调查问题？";
                title.font = [UIFont boldSystemFontOfSize:18];
                [cell addSubview:title];
                [title release];
                
                CGRect frame;
                
                UIImage *heart = [UIImage imageNamed:@"heart.png"];
                UIImageView *heartView = [[UIImageView alloc]initWithImage:heart];
                [heartView setFrame:CGRectMake(15, 60, heart.size.width, heart.size.height)];
                [cell addSubview:heartView];
                [heartView release];
                
                frame = CGRectMake(40, 50, 600, 40);
                UILabel *option_A = [[UILabel alloc]init];
                option_A.backgroundColor = [UIColor clearColor];
                [option_A setFrame:frame];
                option_A.text = @"A. 这里是调查选项";
                option_A.textColor = [UIColor redColor];
                [cell addSubview:option_A];
                [option_A release];
                
                frame.origin.y += 30;
                UILabel *option_B = [[UILabel alloc]init];
                option_B.backgroundColor = [UIColor clearColor];
                [option_B setFrame:frame];
                option_B.text = @"B. 这里是调查选项调查选项";
                [cell addSubview:option_B];
                [option_B release];
                
                frame.origin.y += 30;
                UILabel *option_C = [[UILabel alloc]init];
                option_C.backgroundColor = [UIColor clearColor];
                [option_C setFrame:frame];
                option_C.text = @"C. 这里是调查选项选项";
                [cell addSubview:option_C];
                [option_C release];
                
                frame.origin.y += 30;
                UILabel *option_D = [[UILabel alloc]init];
                option_D.backgroundColor = [UIColor clearColor];
                [option_D setFrame:frame];
                option_D.text = @"D. 这里是调查选项调查选项这里";
                [cell addSubview:option_D];
                [option_D release];
                
                //分割线
                UIImage *line = [UIImage imageNamed:@"background02_line.png"];
                UIImageView *lineView = [[UIImageView alloc]initWithImage:line];
                frame = CGRectMake(20, (200 - line.size.height), (_rightViewController.view.frame.size.width - 20 * 4), line.size.height);
                [lineView setFrame:frame];
                [cell addSubview:lineView];
                [lineView release];
            }
        }
            break;
        //在线考试
        case 2:
        {
            ;
        }
            break;
        //金融咨询
        case 3:
        {
            
        }
            break;
            
        default:
            break;
    }
    
        
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_menuView.currentCellIndex == 1) {
        return 200.f;
    }
    return 250.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [_menuView release];
    [_menuView dealloc];
    [_cellContents release];
//    [_cellContents dealloc];
    [_cellTabViews release];
//    [_cellTabViews dealloc];
    [_centerView release];
    [_centerView dealloc];
    [_backView release];
//    [_backView dealloc];
    [_gridView release];
//    [_gridView dealloc];
    
    [_backgroundMaskView release];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
