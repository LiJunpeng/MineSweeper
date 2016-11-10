//
//  ViewController.m
//  MineSweeper
//
//  Created by LILouis on 11/9/16.
//  Copyright © 2016 LILouis. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

NSArray *mine_board;
NSArray *tile_icons;

NSInteger mine_marked;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    tile_icons = @[[UIImage imageNamed: @"0.png"], [UIImage imageNamed: @"1.png"],[UIImage imageNamed: @"2.png"],[UIImage imageNamed: @"3.png"],[UIImage imageNamed: @"4.png"],[UIImage imageNamed: @"5.png"],[UIImage imageNamed: @"6.png"],[UIImage imageNamed: @"7.png"],[UIImage imageNamed: @"8.png"],[UIImage imageNamed: @"unopen.png"],[UIImage imageNamed: @"question.png"],[UIImage imageNamed: @"flag.png"],[UIImage imageNamed: @"mine.png"],[UIImage imageNamed: @"failed_flag.png"],[UIImage imageNamed: @"explode.png"]];
    
    [self generateBoard];
    
}


- (void) generateBoard {

    for(int i = 1; i <= 64; i++) {
        NSInteger x = 50 + 40 * ((i - 1) % 8);
        NSInteger y =100 + ((i - 1) / 8) * 40;
        [self generateTile: i withX: x withY: y];
    }
    
}


- (void) generateTile: (NSInteger) tag_number withX: (NSInteger) x withY: (NSInteger) y {
    
        UIButton *tile = [UIButton buttonWithType:UIButtonTypeCustom];
//        [tile setTitle: [NSString stringWithFormat:@"%d", tag_number] forState: UIControlStateNormal];
        [tile setTitle: @"" forState: UIControlStateNormal];
        [tile setBackgroundImage:tile_icons[9] forState:UIControlStateNormal];
        [tile.layer setBorderWidth:3.0];
        tile.bounds = CGRectMake(0, 0, 40, 40);

        tile.center = CGPointMake(x, y);
        tile.tag = tag_number;
    NSLog(@"%d",tag_number);
    
        UILongPressGestureRecognizer *long_press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [tile addGestureRecognizer:long_press];
    
        UITapGestureRecognizer *single_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [tile addGestureRecognizer:single_tap];
    
        [self.view addSubview:tile];
    
}


- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIButton *button = (UIButton *)gesture.view;
        [button setBackgroundImage:tile_icons[1] forState:UIControlStateNormal];
    }
}

- (void)singleTap:(UILongPressGestureRecognizer*)gesture {
    UIButton *tile = (UIButton *)gesture.view;
    NSLog(@"%ld", (long)tile.tag);

}


//- (void) buttonTouchUpInside:(UIButton *)button {
//    NSLog(@"push");
//
//}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
