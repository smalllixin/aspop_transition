//
//  ViewController.m
//  Sample
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree. An additional grant
//  of patent rights can be found in the PATENTS file in the same directory.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
//  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ViewController.h"

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <pop/POP.h>

#pragma mark - TransitionNode

@interface TransitionNode : ASDisplayNode
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) ASButtonNode *buttonNode;
@property (nonatomic, strong) ASDisplayNode *colorNode;
@property (nonatomic, strong) ASDisplayNode *flyNode;
@end

@implementation TransitionNode


#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self == nil) { return self; }
    
    self.automaticallyManagesSubnodes = YES;
    
    // Define the layout transition duration for the default transition
    self.defaultLayoutTransitionDuration = 1.0;
    
    _enabled = NO;
    
    _colorNode = [ASDisplayNode new];
    _colorNode.backgroundColor = [UIColor blackColor];
    
    _flyNode = [ASDisplayNode new];
    _flyNode.backgroundColor = [UIColor orangeColor];
    
    // Setup button
    NSString *buttonTitle = @"Start Layout Transition";
    UIFont *buttonFont = [UIFont systemFontOfSize:16.0];
    UIColor *buttonColor = [UIColor blueColor];
    
    _buttonNode = [[ASButtonNode alloc] init];
    [_buttonNode setTitle:buttonTitle withFont:buttonFont withColor:buttonColor forState:ASControlStateNormal];
    
    // Note: Currently we have to set all the button properties to the same one as for ASControlStateNormal. Otherwise
    //       if the button is involved in the layout transition it would break the transition as it does a layout pass
    //       while changing the title. This needs and will be fixed in the future!
    [_buttonNode setTitle:buttonTitle withFont:buttonFont withColor:buttonColor forState:ASControlStateHighlighted];
    return self;
}

- (void)didLoad
{
    [super didLoad];
    
    [self.buttonNode addTarget:self action:@selector(buttonPressed:) forControlEvents:ASControlNodeEventTouchDown];
}

#pragma mark - Actions

- (void)buttonPressed:(id)sender
{
    self.enabled = !self.enabled;
    
    NSLog(@"taptap");
    [self transitionLayoutWithAnimation:YES shouldMeasureAsync:NO measurementCompletion:nil];
}


#pragma mark - Layout

- (ASLayoutSpec *)layoutSpecThatFits:(ASSizeRange)constrainedSize
{
    _colorNode.preferredFrameSize = CGSizeMake(60, 60);
    _flyNode.preferredFrameSize = CGSizeMake(60, 60);
    ASStackLayoutSpec *horizontalStackLayout = [ASStackLayoutSpec horizontalStackLayoutSpec];
    horizontalStackLayout.children = self.enabled?@[_colorNode, _flyNode]:@[_colorNode];
    
    self.buttonNode.alignSelf = ASStackLayoutAlignSelfCenter;
    
    ASStackLayoutSpec *verticalStackLayout = [ASStackLayoutSpec verticalStackLayoutSpec];
    verticalStackLayout.spacing = 10.0;
    verticalStackLayout.children = @[horizontalStackLayout, self.buttonNode];
    
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0) child:verticalStackLayout];
}


//#pragma mark - Transition
//
- (void)animateLayoutTransition:(id<ASContextTransitioning>)context
{
    NSLog(@"piupiu");
    if (self.enabled) {
        CGRect finalFrame = [context finalFrameForNode:_flyNode];
        CGRect beginFrame = finalFrame;
        beginFrame.origin.x += 200;
        _flyNode.frame = beginFrame;
        POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        anim.toValue = [NSValue valueWithCGRect:finalFrame];
        [anim setCompletionBlock:^(POPAnimation *_, BOOL finished) {
            NSLog(@"complete");
            [context completeTransition:finished];
        }];
        [_flyNode.layer pop_addAnimation:anim forKey:@"moveIn"];
    } else {
        CGRect beginFrame = [context initialFrameForNode:_flyNode];
        CGRect finalFrame = beginFrame;
        finalFrame.origin.x += 400;
        _flyNode.frame = beginFrame;
        POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        anim.toValue = [NSValue valueWithCGRect:finalFrame];
        [anim setCompletionBlock:^(POPAnimation *_, BOOL finished) {
            NSLog(@"complete");
            [context completeTransition:finished];
        }];
        [_flyNode.layer pop_addAnimation:anim forKey:@"moveOut"];
    }
}

@end


#pragma mark - ViewController

@interface ViewController ()
@property (nonatomic, strong) TransitionNode *transitionNode;
@end

@implementation ViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _transitionNode = [TransitionNode new];
    [self.view addSubnode:_transitionNode];
    
    // Some debug colors
    _transitionNode.backgroundColor = [UIColor grayColor];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGSize size = [self.transitionNode layoutThatFits:ASSizeRangeMake(CGSizeZero, self.view.frame.size)].size;
    self.transitionNode.frame = CGRectMake(0, 20, size.width, size.height);
}

@end

