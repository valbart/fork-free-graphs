# The fork and the fork-free prime expansions of a claw
F = Graph({1:[2,3,4], 2:[1,5], 3:[1], 4:[1], 5:[2]}) # The fork
H_one = Graph({1:[2,3], 2:[1,4], 3:[1,4,5], 4:[2,3,6], 5:[3,6], 6: [4,5]})
H_two = Graph({1:[2,3,6], 2:[1,3,4], 3:[1,2,5], 4:[2,6], 5:[3,6], 6:[1,4,5]})
H_three = Graph({1:[2,3], 2:[1,4], 3:[1,4,5], 4:[2,3,5,6], 5:[3,4,6], 6: [4,5]})
H_four = Graph({1:[2,3,6], 2:[1,3,4], 3:[1,2,5,6], 4:[2,6], 5:[3,6], 6:[1,3,4,5]})
H_five = Graph({1:[2,3,4,5,6], 2:[1,4,5], 3:[1,4], 4:[1,2,3,5,7], 5:[1,2,4,6,7], 6:[1,5], 7:[4,5]})

# Basics functions for the checker
def is_fork_free(G):
    H = G.subgraph_search(F, induced=True)
    if (H == None): return True
    else: return False

def nr_neighboring_tokens(G, token_positions, u):
    return(len([v for v in G.neighbors(u) if v in token_positions]))

def are_true_twins(G, u, v):
    if (not u in G.neighbors(v)):
        return False
    if (len(G.neighbors(u)) != len(G.neighbors(v))):
        return False
    for x in G.neighbors(v):
        if (x != u and (not x in G.neighbors(u))): return False
    return True

def is_reduced(G, token_positions):
    for u in G.vertices():
        if (nr_neighboring_tokens(G, token_positions, u) >= 3):
            return False
    return True

# A potentially problematic graph is a graph obtained by adding one vertex that holds a token to H_i, and connect
# this new vertex in such a way that the resulting graph is reduced and fork-free. The list token_positions contains
# the initial positions of the tokens in H_i (either {u,v}, {u,w} or {v,w}). The list locally_frozen_vertices contains
# the list of vertices that does not intially contain a token and that are involved in the move sequence. 
# Given a graph H_i, an intial position of the tokens on H_i, and a the set of vertices involved in the move sequence, 
# the function below return a list of all the corresponding potentially problematic graphs. 

def get_list_PPGs(G, token_positions, locally_frozen_vertices):
    PPG_list = []
    for u in locally_frozen_vertices:
        tmp = G.copy()
        new_vertex_label = tmp.order() + 1
        tmp.add_vertex(new_vertex_label)
        tmp.add_edge(new_vertex_label, u)
        potential_neighbors = [i for i in G.vertices() if (i not in token_positions)]
        # potential_neighbors = [i for i in G.vertices() if ((i not in token_positions) 
        #    and (nr_neighboring_tokens(tmp, token_positions, i) <= 1))]
        new_token_positions = token_positions.copy()
        new_token_positions.append(new_vertex_label)
        potential_neighbors_subsets = Subsets(potential_neighbors)
        for s in potential_neighbors_subsets:
            for v in s:
                tmp.add_edge(new_vertex_label, v)
            if (is_fork_free(tmp) and is_reduced(tmp, new_token_positions)):
                PPG_list.append(tmp.copy())
            for v in s: 
                tmp.delete_edge(new_vertex_label, v)
        new_token_positions.remove(new_vertex_label)
    return PPG_list


# Given a potentially problematic graph and the positions of the token on it, the function below 
# check that a token can only move to a vertex that is a true twin of its initial position.
# If true for every token, the set of vertices involved in the move sequence are indeed locally frozen

def check_PPG(G, token_positions):
    for u in token_positions:
        # print("Checking vertex " + str(u))
        tmp = G.copy()
        new_vertex_label = tmp.order() + 1
        tmp.add_vertex(new_vertex_label)
        tmp.add_edge(new_vertex_label, u)
        potential_neighbors = [i for i in G.vertices() if (i not in token_positions)]  
        potential_neighbors_subsets = Subsets(potential_neighbors)
        for s in  potential_neighbors_subsets: 
            for v in s:
                tmp.add_edge(new_vertex_label, v)
            if ((not are_true_twins(tmp, new_vertex_label, u)) and is_fork_free(tmp)):
                # if the graph is fork free we check if a token can move
                for w in tmp.vertices():
                    if (nr_neighboring_tokens(tmp, token_positions, w)) == 1:
                        print("PG Found")
                        return False
            for v in s:
                tmp.delete_edge(new_vertex_label, v)
    return True

# The main checking function: given a graph H_i, the initial position of the tokens on H_i, and a list 
# of vertices involved in the move sequence, check whether their exists a potentially problematic graph,  
# and if it is the case, check wether the vertex of the move sequence are indeed locally frozen

def check_prime_expensions(H, token_positions, locally_frozen_vertices):
    list_PPGs = get_list_PPGs(H, token_positions, locally_frozen_vertices)
    if len(list_PPGs) > 0: 
        nr_PG = 0
        new_vertex_label = H.order() + 1
        token_positions.append(new_vertex_label)
        print(str(len(list_PPGs)) + " PPGs found ")
        for G in list_PPGs:
            if (not check_PPG(G, token_positions)):
                print("PG found")
                nr_PG += 1
        if (nr_PG == 0):
            print("No PG found")
            print("Locally frozen vertices : " + str(locally_frozen_vertices))
    else:
        print("No PPG found")
    print("")

# All the cases to check
print("Graph H_1")
check_prime_expensions(H_one, [1,4], [2,5,6])
check_prime_expensions(H_one, [1,5], [2,4,6])

print("Graph H_2")
check_prime_expensions(H_two, [4,5], [1,2,3])
check_prime_expensions(H_two, [1,4], [2,3,5])

print("Graph H_3")
check_prime_expensions(H_three, [2,3], [1,5,6])
check_prime_expensions(H_three, [2,6], [1,3,5])
check_prime_expensions(H_three, [3,6], [1,2,5])

print("Graph H_4")
check_prime_expensions(H_four, [1,4], [2,3,5])
check_prime_expensions(H_four, [4,5], [1,2,3])
check_prime_expensions(H_four, [1,5], [2,3,4])

print("Graph H_5")
check_prime_expensions(H_five, [2,3], [4,5,6])
check_prime_expensions(H_five, [3,6], [2,4,5])

print("Graph H_6 (2nd claw)")
check_prime_expensions(H_five, [2,3], [1,5,7])
check_prime_expensions(H_five, [3,7], [1,2,5])
check_prime_expensions(H_five, [2,7], [1,3,5])
