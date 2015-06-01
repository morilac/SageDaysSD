︠934a99d0-242b-48dc-8aa2-d0d015c4eaba︠
M=matrix([[1/sqrt(2),0,0],[0,1/sqrt(6),0],[0,0,1/sqrt(3)]])*matrix([[0, 1, -1],[2,-1,-1],[-1,-1,-1]])
reverse=matrix([[0,0,1],[0,1,0],[1,0,0]])
def cproj(Vect):
    V=M*vector(Vect)
    C=[-2*V[0]/V[2],-2*V[1]/V[2]]
    R=2*sqrt(V[0]^2+V[1]^2+V[2]^2)/abs(V[2])
    return [C,R]
def gproj(Vect):
    V=M*vector(Vect)
    N=sqrt(V[0]^2+V[1]^2+V[2]^2)
    G=[2*V[0]/(N-V[2]),2*V[1]/(N-V[2])]
    return G
def ccirc(CR):
    return arc(CR[0], CR[1], sector=(0,2*pi))
def gdot(G):
    return circle(G,.1)
def wall(C,G1,G2):
    CR=cproj(C)
    G1=gproj(G1)
    G2=gproj(G2)
    theta1=arctan2((G1[1]-CR[0][1]),(G1[0]-CR[0][0]))
    theta2=arctan2((G2[1]-CR[0][1]),(G2[0]-CR[0][0]))
    if theta1<theta2:
        A=arc(CR[0], CR[1], sector=(theta1,theta2-2*pi))
    else:
        A=arc(CR[0], CR[1], sector=(theta1,theta2))
    return A
def redwall(C,G1,G2):
    CR=cproj(C)
    G1=gproj(G1)
    G2=gproj(G2)
    theta1=arctan2((G1[1]-CR[0][1]),(G1[0]-CR[0][0]))
    theta2=arctan2((G2[1]-CR[0][1]),(G2[0]-CR[0][0]))
    if theta1<theta2:
        A=arc(CR[0], CR[1], sector=(theta1,theta2-2*pi),color='red')
    else:
        A=arc(CR[0], CR[1], sector=(theta1,theta2),color='red')
    return A
def chamber(S):
    C=S.c_matrix()
    G=S.g_matrix()
    if det(G)<0:
        G=G*reverse
        C=C*reverse
    A=[0,0,0]
    for i in IntegerRange(3):
        CR=cproj(C.column(i%3))
        G1=gproj(G.column((i+1)%3))
        G2=gproj(G.column((i+2)%3))
        theta1=arctan2((G1[1]-CR[0][1]),(G1[0]-CR[0][0]))
        theta2=arctan2((G2[1]-CR[0][1]),(G2[0]-CR[0][0]))
        if (C.column(i%3)[0]+C.column(i%3)[1]+C.column(i%3)[2])>0:
            if theta1<theta2:
                A[i]=arc(CR[0], CR[1], sector=(theta1,theta2-2*pi))
            else:
                A[i]=arc(CR[0], CR[1], sector=(theta1,theta2))
        else:
            if theta2<theta1:
                A[i]=arc(CR[0], CR[1], sector=(theta2,theta1-2*pi))
            else:
                A[i]=arc(CR[0], CR[1], sector=(theta2,theta1))
    return A[0]+A[1]+A[2]

︡9e41b4a9-cfc6-405f-b72d-9d5f248e6518︡
︠fcc966ee-9daa-4cd0-b943-164a1d18aa88︠
S=ClusterSeed(matrix([[0,2,-2],[-2,0,2],[2,-2,0]])).principal_extension()
A=chamber(S)
C=S.mutation_class(depth=3)
for i in C:
    A=A+chamber(i)
A+ccirc(cproj([1,1,1]))
︡358211fe-40a5-4f7c-b740-747b3f489dde︡{"once":false,"file":{"show":true,"uuid":"f4fdd194-b1be-46f7-b367-44654d7e660e","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute7dc1/2634/tmp_hhiVuJ.svg"}}︡{"html":"<div align='center'></div>"}︡
︠65d5fc14-9dac-4700-a7d6-f58cba661993︠
S=ClusterSeed(matrix([[0,3,-3],[-3,0,3],[3,-3,0]])).principal_extension()
A=chamber(S)
C=S.mutation_class(depth=3)
for i in C:
    A=A+chamber(i)
A+ccirc(cproj([1,1,1]))
︡2a3400d7-dc56-42a1-8471-2dbb60494ec5︡{"once":false,"file":{"show":true,"uuid":"1fa4e884-e399-4cc2-b01e-53751e24aeb0","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute7dc1/2634/tmp_zhaidb.svg"}}︡{"html":"<div align='center'></div>"}︡
︠e9f183ef-e8f4-4be1-b431-ad30aad11ade︠
S=ClusterSeed(matrix([[0,3,-3],[-3,0,3],[3,-3,0]])).principal_extension()
A=chamber(S)
C=S.mutation_class(depth=4)
for i in C:
    A=A+chamber(i)
A+ccirc(cproj([1,1,1]))
︡b7b55e8a-01cc-4ec6-8ece-671e6e83d54b︡{"once":false,"file":{"show":true,"uuid":"fbad930d-7b87-4a2f-a7d7-c56508b41af0","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute7dc1/2634/tmp_1uU6Ao.svg"}}︡{"html":"<div align='center'></div>"}︡
︠2d7f6650-518a-4625-afb8-2e06c69ac4b4︠
A=ccirc(cproj([1,0,0]))+ccirc(cproj([0,1,0]))+ccirc(cproj([0,0,1]))
A
︡524ce4e5-8edd-4e11-9622-476b8ce6d1cc︡{"once":false,"file":{"show":true,"uuid":"9bdbcf87-b2c3-49db-9c26-db4330575766","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute7dc1/2634/tmp_V0KetY.svg"}}︡{"html":"<div align='center'></div>"}︡
︠444feefd-27fa-4014-867b-36a68a653fa2︠
#degree 3
A=A+wall([2,1,0],[0,0,1],[0,0,-1])
A=A+wall([1,2,0],[0,0,1],[0,0,-1])
A=A+wall([0,2,1],[1,0,0],[-1,0,0])
A=A+wall([0,1,2],[1,0,0],[-1,0,0])
A
︡b4d93182-a685-4c31-bb6c-d6a63b6259c9︡{"once":false,"file":{"show":true,"uuid":"02d626f5-34f0-4718-b963-eb724f9f4c48","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute7dc1/2634/tmp_i_oMoZ.svg"}}︡{"html":"<div align='center'></div>"}︡
︠2ca87456-41e1-4808-814c-dffba2527407︠
#degree 4
A=A+redwall([2,2,0],[0,0,1],[0,0,-1])
A=A+redwall([0,2,2],[1,0,0],[-1,0,0])
A=A+wall([3,0,1],[0,1,0],[0,-1,0])
A=A+wall([1,0,3],[0,1,0],[0,-1,0])
A

︡8e1b8c26-f09c-4da1-9b40-1af49e57eb37︡{"once":false,"file":{"show":true,"uuid":"2da20fdd-bbf3-4f83-b783-88f313b35d21","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute7dc1/2634/tmp_qD2VPm.svg"}}︡{"html":"<div align='center'></div>"}︡
︠3941da50-be54-4a7b-a1ff-27a251735c5e︠


A=A+wall([4,3,0],[0,0,1],[0,0,-1])
A=A+wall([5,4,0],[0,0,1],[0,0,-1])
A=A+wall([3,2,0],[0,0,1],[0,0,-1])
A=A+wall([4,3,0],[0,0,1],[0,0,-1])
A=A+wall([5,4,0],[0,0,1],[0,0,-1])
A=A+wall([2,3,0],[0,0,1],[0,0,-1])
A=A+wall([3,2,0],[0,0,1],[0,0,-1])
A=A+wall([4,3,0],[0,0,1],[0,0,-1])
A=A+wall([5,4,0],[0,0,1],[0,0,-1])
A=A+wall([2,2,0],[0,0,1],[0,0,-1])
A=A+wall([4,0,2],[0,1,0],[0,-1,0])
A=A+wall([5,0,3],[0,1,0],[0,-1,0])
A=A+wall([6,0,4],[0,1,0],[0,-1,0])
A=A+wall([2,0,4],[0,1,0],[0,-1,0])
A=A+wall([3,0,5],[0,1,0],[0,-1,0])
A=A+wall([4,0,6],[0,1,0],[0,-1,0])
#A=A+wall([3,0,3],[0,1,0],[0,-1,0])
A=A+wall([0,3,2],[1,0,0],[-1,0,0])
A=A+wall([0,4,3],[1,0,0],[-1,0,0])
A=A+wall([0,5,4],[1,0,0],[-1,0,0])
A=A+wall([0,2,3],[1,0,0],[-1,0,0])
A=A+wall([0,3,4],[1,0,0],[-1,0,0])
A=A+wall([0,4,5],[1,0,0],[-1,0,0])
A
︡794fd0a1-046c-4403-8986-5a4ac68a0fb5︡{"once":false,"file":{"show":true,"uuid":"b7dc09e8-6d2f-4448-a859-ee38cbc6beb9","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute7dc1/2634/tmp_RpI9V4.svg"}}︡{"html":"<div align='center'></div>"}︡
︠15c098bd-b33e-4995-b628-a96e37db8017︠
S=ClusterSeed(matrix([[0,2,-3],[-2,0,2],[3,-2,0]])).principal_extension()
S.interact()
︡a75c62df-64d9-4aab-acf3-c2212ec5a7d5︡{"stdout":"'The interactive mode only runs in the Sage notebook.'\n"}︡
︠09b1be38-397c-45fc-a05b-b85ad9973750︠









