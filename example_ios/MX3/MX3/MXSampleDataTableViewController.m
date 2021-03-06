#import "MXSampleDataTableViewController.h"
#import "gen/MX3UserListVmCell.h"
#import "gen/MX3ListChange.h"

NSString *const CellIdentifier = @"MX3Cell";

@interface MXSampleDataTableViewController ()

@property (nonatomic) id <MX3Api> api;
@property (nonatomic) id <MX3UserListVmHandle> handle;
@property (nonatomic) id <MX3UserListVm> viewModel;

@end

@implementation MXSampleDataTableViewController

- (instancetype) initWithApi:(id<MX3Api>)api {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.api = api;
        self.handle = [api observerUserList];
        self.viewModel = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [self.api getUsername];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:CellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    // todo(piet) what is the proper 'weak-ref' style here
    [self.handle start:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.handle stop];
}

- (void)onUpdate:(NSMutableArray *)changes newData:(id <MX3UserListVm>)newData {
    if (changes) {
        [self.tableView beginUpdates];
        for (MX3ListChange *change in changes) {
            if (change.fromIndex >= 0 && change.toIndex >= 0) {
                NSUInteger indexes[] = {0, change.toIndex};
                NSIndexPath *path = [NSIndexPath indexPathWithIndexes:indexes length:2];
                [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (change.fromIndex >= 0) {
                NSUInteger indexes[] = {0, change.fromIndex};
                NSIndexPath *path = [NSIndexPath indexPathWithIndexes:indexes length:2];
                [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                NSUInteger indexes[] = {0, change.toIndex};
                NSIndexPath *path = [NSIndexPath indexPathWithIndexes:indexes length:2];
                [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        self.viewModel = newData;
        [self.tableView endUpdates];
    } else {
        self.viewModel = newData;
        [self.tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel != nil ? [self.viewModel count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];

    MX3UserListVmCell * cellData = [self.viewModel get:indexPath.row];
    cell.textLabel.text = [cellData name];
    cell.detailTextLabel.text = @"If you manage to get the deps right";
    return cell;
}

@end
