//
//  SSCheckoutCustomerEditViewController.m
//  iPOS
//
//  Created by Enning Tang on 7/31/12.
//  Copyright (c) 2012 TILESHOP. All rights reserved.
//

#import "SSCheckoutCustomerEditViewController.h"
#import "IBAInputManager.h"
#import "UIViewController+ViewControllerLayout.h"
#import "UIViewController+Helpers.h"

#import "AlertUtils.h"

#import "Customer.h"

#import "SSCartItemsViewController.h"
#import "SSLookupCustomerViewController.h"
#import "SSCheckoutCustomerDetailViewController.h"
#import "SSCheckoutCustomerListViewController.h"

#pragma mark -
#pragma mark Private Interface
@interface SSCheckoutCustomerEditViewController ()
- (void) saveCustomer:(id)sender;
- (void) confirmCustomer:(id)sender;

@end

#pragma mark -
@implementation SSCheckoutCustomerEditViewController

@synthesize lastSavedCustomer;
@synthesize itemDescription;
@synthesize itemQty;
@synthesize itemSku;
@synthesize itemUOM;

#pragma mark Constructors
#pragma mark -
#pragma mark init/dealloc
- (id) init {
    self = [super init];
    
    if (self) {
        if (self.navigationController != nil) 
        {
            [self.navigationController setNavigationBarHidden:NO];
            [[self navigationItem] setTitle:@"Edit Customer"];
            [self setTitle:@"Edit Customer"];
        }
    }
    
    return self;
}

- (void) dealloc {
	[self setLastSavedCustomer:nil];
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

#pragma mark -
#pragma mark UIViewController overrides

- (void) loadView {
	[super loadView];
	
	orderCart = [SSOrderCart sharedInstance];
    facade = [iPOSFacade sharedInstance];
	
	UITableView *formTableView = [[[UITableView alloc] initWithFrame:[self rectForNav] style:UITableViewStyleGrouped] autorelease];
	[formTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	formTableView.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
	
	[self setTableView:formTableView];
	[self setView:formTableView];
}

- (void) viewDidLoad {
    [super viewDidLoad];
}	

- (void) viewWillAppear:(BOOL)animated {
	if (self.navigationController != nil) {
		[self.navigationController setNavigationBarHidden:NO];
		self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cust Edit" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
		NSMutableDictionary *custModel = [[self formDataSource] model];
		NSNumber *custId = [custModel objectForKey:@"customerId"];
		if (custId != nil && ![custId isEqualToNumber:[NSNumber numberWithInt:0]]) {
			UIBarButtonItem *confirmButton = [[[UIBarButtonItem alloc] init] autorelease];
			confirmButton.title = @"Confirm";
			confirmButton.target = self;
			[confirmButton setAction:@selector(confirmCustomer:)];
			[self.navigationItem setRightBarButtonItem:confirmButton];
			// save the initial state of the customer so we can tell if we changed it before committing
			[self setLastSavedCustomer:[[custModel copy] autorelease]];
            
		} else {
			UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] init] autorelease];
			saveButton.title = @"Save";
			saveButton.target = self;
			[saveButton setAction:@selector(saveCustomer:)];
			[self.navigationItem setRightBarButtonItem:saveButton];
		}
    }
	[super viewWillAppear:animated];
}

- (void) saveCustomer:(id)sender {
	NSLog(@"Got save customer button press");
	
	// If we have an active input requestor that means there is a keyboard or
	// some other form component up.  This should dismiss it like the Done
	// button on the toolbar had been pressed.
	IBAInputManager *ibaInputManager = [IBAInputManager sharedIBAInputManager];
	if ([ibaInputManager activeInputRequestor] != nil) {
		[ibaInputManager setActiveInputRequestor:nil];
	}
	
	NSMutableDictionary *custModel = [[self formDataSource] model];
	NSLog(@"Current customer model:");
	NSLog(@"%@", [custModel description]);
	Customer *editedCust = [[[Customer alloc] initWithModel:custModel] autorelease];
    
	[facade newCustomer:editedCust];
    
	if ( ([editedCust errorList] != nil) && ([[editedCust errorList] count] > 0) ) {
		NSMutableString *errMsg = [[[NSMutableString alloc] init] autorelease];
		[errMsg appendString:@"Error in customer save"];
		for (Error *e in [editedCust errorList]) {
			NSLog(@"Error Id: %@ %@", [e errorId], [e message]);
			[errMsg appendFormat:@"\nError (%@): %@", [e errorId], [e message]];
		}
		[AlertUtils showModalAlertMessage:errMsg withTitle:@"iPOS"];
	} else {
		NSLog(@"No errors from new customer call");
		NSMutableDictionary *updatedModel = [editedCust modelFromCustomer];
		[self setLastSavedCustomer:updatedModel];
		NSLog(@"updated model:");
		NSLog(@"%@", [updatedModel description]);
		[updatedModel enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			NSLog(@"Enumerating Key %@ and Value %@",key,obj);
			[[self formDataSource] setModelValue:obj forKeyPath:key];
		}];
		
		[[self tableView] reloadData];
		
		// Switch over to a confirm button now.
		[self.navigationItem setRightBarButtonItem:nil];
		UIBarButtonItem *confirmButton = [[[UIBarButtonItem alloc] init] autorelease];
		confirmButton.title = @"Confirm";
		confirmButton.target = self;
		[confirmButton setAction:@selector(confirmCustomer:)];
		[self.navigationItem setRightBarButtonItem:confirmButton];
	}
	
}

- (void) confirmCustomer:(id)sender {
	NSLog(@"Got confirm customer button press");
	
	// If we have an active input requestor that means there is a keyboard or
	// some other form component up.  This should dismiss it like the Done
	// button on the toolbar had been pressed.
	IBAInputManager *ibaInputManager = [IBAInputManager sharedIBAInputManager];
	if ([ibaInputManager activeInputRequestor] != nil) {
		[ibaInputManager setActiveInputRequestor:nil];
	}
	
	NSMutableDictionary *custModel = [[self formDataSource] model];
	NSLog(@"Current customer model:");
	NSLog(@"%@", [custModel description]);
	if ([self lastSavedCustomer] != nil) {
		NSLog(@"Last Saved Customer model:");
		NSLog(@"%@", [[self lastSavedCustomer] description]);
	}
	
	Customer *editedCust = [[[Customer alloc] initWithModel:custModel] autorelease];
	
	if ([self lastSavedCustomer] == nil || ([[self lastSavedCustomer] isEqualToDictionary:custModel] == NO)) {
		NSLog(@"Updating customer on commit because it changed.");
		[facade updateCustomer:editedCust];
	}
	
	if ( ([editedCust errorList] != nil) && ([[editedCust errorList] count] > 0) ) {
		NSMutableString *errMsg = [[[NSMutableString alloc] init] autorelease];
		[errMsg appendString:@"Error in customer update!"];
		for (Error *e in [editedCust errorList]) {
			NSLog(@"Error Id: %@ %@", [e errorId], [e message]);
			[errMsg appendFormat:@"\nError (%@): %@", [e errorId], [e message]];
		}
		[AlertUtils showModalAlertMessage:errMsg withTitle:@"iPOS"];
	} else {
		NSLog(@"No errors in customer");
		NSMutableDictionary *updatedModel = [editedCust modelFromCustomer];
		Customer *custCopy = [[[Customer alloc] initWithModel:updatedModel] autorelease];
        
        // Bind the customer to the order cart
		[orderCart bindCustomerToOrder:custCopy];
        
        if (custCopy.errorList && [custCopy.errorList count] > 0) {
            [AlertUtils showModalAlertForErrors:custCopy.errorList withTitle:@"iPOS"];
            return;
        }
		
		// This is where you pop to the order cart or pop the customer controllers and push the order cart
        //UIViewController *cartItemsController = [self getOnNavStackByType:[CartItemsViewController class]];
        
        //=====================================updated
        SSCartItemsViewController *cartItemsController = [[SSCartItemsViewController alloc]init];
        [[self navigationController] pushViewController:cartItemsController animated:TRUE];
        
        if (cartItemsController) {
            [self.navigationController popToViewController:cartItemsController animated:YES];
        } else {
            // Pop all relevant customer controllers including self
            UINavigationController *navController = self.navigationController;
            UIViewController *custDetailController = [self getOnNavStackByType:[SSCheckoutCustomerDetailViewController class]];
            UIViewController *custListController = [self getOnNavStackByType:[SSCheckoutCustomerListViewController class]];
            UIViewController *custController = [self getOnNavStackByType:[SSLookupCustomerViewController class]];
            
            
            [[self retain] autorelease];
            
            // Pop all customer related view controllers
            [navController popViewControllerAnimated:NO];
            
            if (custDetailController) {
                [navController popViewControllerAnimated:NO];
            }
            if (custListController) {
                [navController popViewControllerAnimated:NO];
            }
            if (custController) {
                [navController popViewControllerAnimated:NO];
            }
            
            // Push the cart items controller
            SSCartItemsViewController *cartItemsController = [[SSCartItemsViewController alloc] init];
            [navController pushViewController:cartItemsController animated:YES];
            [cartItemsController release];
        }
        
		
	}
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

@end

