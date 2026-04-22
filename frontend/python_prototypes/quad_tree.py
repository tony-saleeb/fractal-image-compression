import random
import matplotlib.pyplot as plt
import matplotlib.patches as patches

# Quadtree Node Class
class QuadTreeNode:
    def __init__(self, x, y, width, height, capacity):
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.capacity = capacity
        self.points = []
        self.divided = False
        self.north_west = None
        self.north_east = None
        self.south_west = None
        self.south_east = None

    def subdivide(self):
        w = self.width / 2
        h = self.height / 2
        
        self.north_west = QuadTreeNode(self.x, self.y, w, h, self.capacity)
        self.north_east = QuadTreeNode(self.x + w, self.y, w, h, self.capacity)
        self.south_west = QuadTreeNode(self.x, self.y + h, w, h, self.capacity)
        self.south_east = QuadTreeNode(self.x + w, self.y + h, w, h, self.capacity)
        
        self.divided = True

    def insert(self, point):
        # Point is (x, y)
        if not self.contains(point):
            return False

        if len(self.points) < self.capacity:
            self.points.append(point)
            return True
        else:
            if not self.divided:
                self.subdivide()
            
            if self.north_west.insert(point): return True
            if self.north_east.insert(point): return True
            if self.south_west.insert(point): return True
            if self.south_east.insert(point): return True
            
        return False

    def contains(self, point):
        px, py = point
        return (self.x <= px < self.x + self.width and
                self.y <= py < self.y + self.height)

    def query(self, range_rect, found_points):
        # range_rect = (x, y, w, h)
        if not self.intersects(range_rect):
            return

        for p in self.points:
            if self.rect_contains(range_rect, p):
                found_points.append(p)

        if self.divided:
            self.north_west.query(range_rect, found_points)
            self.north_east.query(range_rect, found_points)
            self.south_west.query(range_rect, found_points)
            self.south_east.query(range_rect, found_points)

    def intersects(self, range_rect):
        rx, ry, rw, rh = range_rect
        return not (rx > self.x + self.width or
                    rx + rw < self.x or
                    ry > self.y + self.height or
                    ry + rh < self.y)

    def rect_contains(self, rect, point):
        rx, ry, rw, rh = rect
        px, py = point
        return (rx <= px < rx + rw and
                ry <= py < ry + rh)

# Visualization Function
def draw_quadtree(node, ax):
    rect = patches.Rectangle((node.x, node.y), node.width, node.height, linewidth=1, edgecolor='r', facecolor='none')
    ax.add_patch(rect)
    
    if node.divided:
        draw_quadtree(node.north_west, ax)
        draw_quadtree(node.north_east, ax)
        draw_quadtree(node.south_west, ax)
        draw_quadtree(node.south_east, ax)

# Main Execution
if __name__ == "__main__":
    # Create a Quadtree boundary (0, 0, 400, 400)
    qt = QuadTreeNode(0, 0, 400, 400, 4) # Capacity 4

    # Insert random points
    points = []
    print("Inserting 50 random points...")
    for i in range(50):
        p = (random.uniform(0, 400), random.uniform(0, 400))
        qt.insert(p)
        points.append(p)
        print(f"Inserted: {p}")

    # Visualize
    fig, ax = plt.subplots(1)
    ax.set_xlim(0, 400)
    ax.set_ylim(400, 0) # Flip Y to match screen coords logic usually
    
    # Draw points
    x_coords = [p[0] for p in points]
    y_coords = [p[1] for p in points]
    ax.scatter(x_coords, y_coords, s=10, c='blue')

    # Draw Quadtree
    draw_quadtree(qt, ax)

    plt.title("Quadtree Visualization (Capacity=4)")
    plt.show()
