from collections import deque
import networkx as nx
import matplotlib.pyplot as plt

# Breadth First Search Implementation
def broad_search(graph, start_node, target_node=None):
    """
    Performs Breadth-First Search on a graph.
    If target_node is provided, stops when found.
    Returns: list of visited nodes in order.
    """
    queue = deque([start_node])
    visited = {start_node}
    traversal_order = []

    print(f"Starting BFS from node: {start_node}")

    while queue:
        current_node = queue.popleft()
        traversal_order.append(current_node)
        print(f"Visiting: {current_node}")

        if current_node == target_node:
            print(f"Target {target_node} found!")
            break

        for neighbor in graph[current_node]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)
                print(f"  -> Queuing neighbor: {neighbor}")

    return traversal_order

# Visualization
def visualize_graph_bfs(graph, traversal_order):
    G = nx.Graph(graph)
    pos = nx.spring_layout(G)
    
    plt.figure(figsize=(10, 6))
    
    # Draw all nodes
    nx.draw(G, pos, with_labels=True, node_color='lightgray', node_size=2000, font_weight='bold')
    
    # Highlight path
    path_edges = []
    # Note: BFS traversal order doesn't purely form a single path line visually, 
    # but we can color the nodes in order
    
    # Animate or show colored nodes
    color_map = []
    for node in G:
        if node in traversal_order:
            color_map.append('lightgreen')
        else:
            color_map.append('lightgray')
            
    nx.draw(G, pos, with_labels=True, node_color=color_map, node_size=2000, font_weight='bold')
    plt.title(f"BFS Traversal Order: {traversal_order}")
    plt.show()

# Main Execution
if __name__ == "__main__":
    # Define a simple graph as an adjacency list
    my_graph = {
        'A': ['B', 'C'],
        'B': ['A', 'D', 'E'],
        'C': ['A', 'F'],
        'D': ['B'],
        'E': ['B', 'F'],
        'F': ['C', 'E']
    }

    print("Graph Structure:", my_graph)
    
    start = 'A'
    order = broad_search(my_graph, start)
    
    print("\nFinal BFS Traversal Order:", order)
    
    # Optional: Visualize if networkx/matplotlib installed
    try:
        visualize_graph_bfs(my_graph, order)
    except ImportError:
        print("Install networkx and matplotlib to see the visualization.")
