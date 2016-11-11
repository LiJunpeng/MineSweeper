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

UIButton *start_button;
UIButton *cheat_button;

NSMutableArray *button_array;
NSMutableArray *mine_array;
NSMutableArray *status_array;
NSArray *tile_icons;

//NSInteger mine_marked;
NSInteger rows;
NSInteger cols;
NSInteger mines;
BOOL cheat_mode;  // need?
NSInteger game_status;  // 0 - not in gmae, 1 - in game,


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // init icon array
    tile_icons = @[[UIImage imageNamed: @"0.png"], [UIImage imageNamed: @"1.png"],[UIImage imageNamed: @"2.png"],[UIImage imageNamed: @"3.png"],[UIImage imageNamed: @"4.png"],[UIImage imageNamed: @"5.png"],[UIImage imageNamed: @"6.png"],[UIImage imageNamed: @"7.png"],[UIImage imageNamed: @"8.png"],[UIImage imageNamed: @"unopen.png"],[UIImage imageNamed: @"question.png"],[UIImage imageNamed: @"flag.png"],[UIImage imageNamed: @"mine.png"],[UIImage imageNamed: @"failed_flag.png"],[UIImage imageNamed: @"explode.png"]];
    
    // set up UI
    // create cheat button
    UIButton *cheat_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [cheat_button setTitle: @"Cheat?" forState: UIControlStateNormal];
    [cheat_button.layer setBorderWidth:1.0];
    cheat_button.bounds = CGRectMake(0, 0, 100, 30);
    cheat_button.center = CGPointMake(320.0 * 2 / 3, 40);
    cheat_button.tag = -2;     // just in case
    [cheat_button addTarget:self action:@selector(cheatButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cheat_button];
    
    // create start button
    UIButton *start_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [start_button setTitle: @"Start" forState: UIControlStateNormal];
    [start_button.layer setBorderWidth:1.0];
    start_button.bounds = CGRectMake(0, 0, 100, 30);
    start_button.center = CGPointMake(320.0 * 1 / 3, 40);
    start_button.tag = -1;
    [start_button addTarget:self action:@selector(startGame:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:start_button];
    
}

- (void) initGame {
    
    [self generateBoard];
    cheat_mode = false;
    
}


- (void) generateBoard {
    
    rows = 12;
    cols = 8;
    mines = 8;

    button_array = [[NSMutableArray alloc] init];  // init button array
    [button_array addObject: @"spare"];     // add object for [0]
    for(int i = 1; i <= rows; i++) {     // array index start from 1
        for(int j = 1; j <= cols; j++ ) {
            NSInteger tag_number = j + (i - 1) * cols;
            NSInteger x = 40 * j;             // cord-x
            NSInteger y =100 + (i - 1) * 40;  // cord-y
            [button_array addObject: [self generateTile: tag_number withX: x withY: y]];
        }
    }
    
    mine_array = [[NSMutableArray alloc] init];   // init mine array to all 0s
    for(int i = 0; i <= rows * cols; i++) {
        [mine_array addObject: [NSNumber numberWithInt:0]];
    }
    
    status_array = [[NSMutableArray alloc] init];  // init status array to all 9s (unopen)
    for(int i = 0; i <= rows * cols; i++) {
        [status_array addObject: [NSNumber numberWithInt:9]];
    }
    
    NSInteger count = 0;
    while(count < mines) {   // randomly generate mines in mine_array
        NSInteger random_number = arc4random_uniform(rows * cols - 1) + 1;
        if([[mine_array objectAtIndex: random_number]intValue] == 1) {
            continue;
        }
        [mine_array replaceObjectAtIndex: random_number withObject: [NSNumber numberWithInt:1]];
        count++;
    }
    
}


- (UIButton*) generateTile: (NSInteger) tag_number withX: (NSInteger) x withY: (NSInteger) y {
    // generate tiles for board
    UIButton *tile = [UIButton buttonWithType:UIButtonTypeCustom];
    [tile setTitle: @"" forState: UIControlStateNormal];
    [tile setBackgroundImage:tile_icons[9] forState:UIControlStateNormal];
    [tile.layer setBorderWidth:1.0];
    tile.bounds = CGRectMake(0, 0, 40, 40);
    tile.center = CGPointMake(x, y);
    tile.tag = tag_number;
    
    UILongPressGestureRecognizer *long_press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [tile addGestureRecognizer:long_press];

    UITapGestureRecognizer *single_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [tile addGestureRecognizer:single_tap];

    [self.view addSubview:tile];
    return tile;
}

- (void) revealBoard {  // reveal mines in cheat mode
    for(int i = 1; i <= rows * cols; i++) {
        if([[mine_array objectAtIndex:i] intValue] == 1) {
            UIButton *button = [button_array objectAtIndex:i];
            [button setBackgroundImage:tile_icons[12] forState:UIControlStateNormal];
        }
    }
}

//- (void) concealBoard {
//    for(int i = 1; i <= rows * cols; i++) {
//        UIButton *button = [button_array objectAtIndex:i];
//        NSInteger status = [[status_array objectAtIndex:i] intValue];
//        [button setBackgroundImage:tile_icons[status] forState:UIControlStateNormal];
//    }
//}

- (void) updateBoardUI {   // set up UI basing on status array
    for(int i = 1; i <= rows * cols; i++) {
        UIButton *button = [button_array objectAtIndex:i];
        NSInteger status = [[status_array objectAtIndex:i] intValue];
        [button setBackgroundImage:tile_icons[status] forState:UIControlStateNormal];
    }
}

- (void) checkForWin {    // check if player win
    int count = 0;        // count how many unopen tiles left
    int question_marked = 0;  // count how many tiles are marked as question
    int mine_marked = 0;      // count how many mines are correctly marked
    for(int i = 1; i <= rows * cols; i++) {
        int tile_status = [[status_array objectAtIndex:i] intValue];
        int tile_has_mine = [[mine_array objectAtIndex:i] intValue];
        
        if(tile_status == 11 && tile_has_mine == 0) {  // marked empty tile, not win
            return;
        }
        
        if(tile_status == 9 || tile_status == 10 || tile_status == 11) { // count unopened tiles
            count++;
            if(tile_status == 11 && tile_has_mine == 1) {
                mine_marked++;
            } else if (tile_status == 10) {
                question_marked++;
            }
        }
    }
    
    NSLog(@"%d and marked: %d", count, mine_marked);
    
    if(count == mines || (mine_marked == mines && question_marked == 0)) { // if unopenned tiles or marked mine == mines, win
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You win!"
                                                        message:@"Easy!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        game_status = 0;
    }
}

- (int) countSurroundMines: (int) tile{
    
    int count = 0;
    int total_tiles = cols * rows;
    
    int top_left = tile - cols - 1;
    if(top_left > 0 && top_left % cols != 0 && [[mine_array objectAtIndex: top_left] intValue] == 1) count++;
    
    int top = tile - cols;
    if(top > 0 && [[mine_array objectAtIndex: top] intValue] == 1) count++;
    
    int top_right = tile - cols + 1;
    if(top_right > 0 && top_right % cols != 1 && [[mine_array objectAtIndex: top_right] intValue] == 1) count++;
    
    int left = tile - 1;
    if(left > 0 && left % cols != 0 && [[mine_array objectAtIndex: left] intValue] == 1) count++;
    
    int right = tile + 1;
    if(right <= total_tiles && right % cols != 1 && [[mine_array objectAtIndex: right] intValue] == 1) count++;
    
    int bottom_left = tile + cols - 1;
    if(bottom_left <= total_tiles && bottom_left % cols != 0 && [[mine_array objectAtIndex: bottom_left] intValue] == 1) count++;
    
    int bottom = tile + cols;
    if(bottom <= total_tiles && [[mine_array objectAtIndex: bottom] intValue] == 1) count++;
    
    int bottom_right = tile + cols + 1;
    if(bottom_right <= total_tiles && bottom_right % cols != 1 && [[mine_array objectAtIndex: bottom_right] intValue] == 1) count++;
    
    return count;
}

- (void) blowUp:(int) blow_mine {  // if user hit a mine
    game_status = 0;
    
    for(int i = 1; i <= rows * cols; i++) {  // update status array to display end game UI
        int tile_status = [[status_array objectAtIndex:i] intValue];
        int tile_has_mine = [[mine_array objectAtIndex:i] intValue];
        
        if(i == blow_mine) {   // mark the blown mine
            [status_array replaceObjectAtIndex: blow_mine withObject: [NSNumber numberWithInt:14]];
            continue;
        }
        
        if(tile_status == 11 && tile_has_mine == 0) {  // mark false flagged tile
            [status_array replaceObjectAtIndex: i withObject: [NSNumber numberWithInt:13]];
            continue;
        }
        
        if(tile_status != 11 && tile_has_mine == 1) {  // mark unmarked mine
            [status_array replaceObjectAtIndex: i withObject: [NSNumber numberWithInt:12]];
            continue;
        }
    }
    
    [self updateBoardUI];  // refresh board display
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boooooom!!!"
                                                    message:@"爆炸吧，现充！！！"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)longPress:(UILongPressGestureRecognizer*)gesture {
    if(game_status == 1 && !cheat_mode) {  // playing game without cheat
        if (gesture.state == UIGestureRecognizerStateBegan) {
            UIButton *button = (UIButton *)gesture.view;   // get button object
            NSInteger status = [[status_array objectAtIndex: button.tag] intValue];  // get button status
            
            if(status == 9) { // mark flag
                [status_array replaceObjectAtIndex:button.tag withObject: [NSNumber numberWithInt: 11]];
            } else if(status == 11) {  // mark question mark
                [status_array replaceObjectAtIndex:button.tag withObject: [NSNumber numberWithInt: 10]];
            } else if(status == 10) {  // clear mark
                [status_array replaceObjectAtIndex:button.tag withObject: [NSNumber numberWithInt: 9]];
            }
            
            [self checkForWin];
            [self updateBoardUI];
        }
    }
}

- (void)singleTap:(UILongPressGestureRecognizer*)gesture {
    UIButton *tile = (UIButton *)gesture.view;
    NSLog(@"%ld", (long)tile.tag);
    
    if(game_status == 1 && !cheat_mode) {  // playing game without cheat
        if([[status_array objectAtIndex: tile.tag] intValue] == 9) {  // if tap on unopenned tile
            if([[mine_array objectAtIndex: tile.tag] intValue] == 0) {  // if it's an empty tile
                [self open: tile];  // iteratively open tile and it's surrounding tiles
                [self updateBoardUI];
                [self checkForWin];
            } else {
                [self blowUp: tile.tag];  // blow up when tap on a mine tile
            }
        }
    }
    else {NSLog(@"%d", tile.tag);}// debug use
}

- (void) open: (UIButton*) root {  // iteratively open tiles
    int mine_count = [self countSurroundMines: root.tag];  // count mines surrounding

    [status_array replaceObjectAtIndex:root.tag withObject: [NSNumber numberWithInt: mine_count]];  // change self status basing on the mines counts
    if(mine_count == 0) {  // if there is no mine in it's surrounding, check tiles on it top, left, right, and bottom
        
        int total_tiles = cols * rows;
        
        int top = root.tag - cols;
        if(top > 0 && [[status_array objectAtIndex: top] intValue] == 9) [self open: [button_array objectAtIndex: top]];
    
        int left = root.tag - 1;
        if(left > 0 && left % cols != 0 && [[status_array objectAtIndex: left] intValue] == 9) [self open: [button_array objectAtIndex: left]];

        int right = root.tag + 1;
        if(right <= total_tiles && right % cols != 1 && [[status_array objectAtIndex: right] intValue] == 9) [self open: [button_array objectAtIndex: right]];

        int bottom = root.tag + cols;
        if(bottom <= total_tiles && [[status_array objectAtIndex: bottom] intValue] == 9) [self open: [button_array objectAtIndex: bottom]];
    }
}

- (void) cheatButtonPushed:(UIButton *)button {
    if(game_status == 1) {
        cheat_mode = !cheat_mode;
        if(cheat_mode) {
            [button setTitle: @"Stop Cheat" forState: UIControlStateNormal];
        } else {
            [button setTitle: @"Cheat?" forState: UIControlStateNormal];
        }
        [self toggleCheatMode];
    }
}

- (void) toggleCheatMode{
    if(cheat_mode) {
        [self revealBoard];
    } else {
        [self updateBoardUI];
    }
}

- (void) startGame:(UIButton *)button {
    if(game_status == 0) {
        game_status = 1;
        [self initGame];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
