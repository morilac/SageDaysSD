︠5eb3254e-f571-4a56-b517-004312f2cb67︠
class SDTable():
    """
        SDTable() initializes an object containing a dictionary of model scattering diagrams, for the purpose of looking up multiplicities in collisions
    """
    def __init__(self):
        self.diagrams= {};

    def __repr__(self):
        return "A table of model scattering diagrams"

    def multiplicity(self,d,n,verbose=False):
        """
            multiplicity() looks up the desired multiplicity, and creates or improves the table as necessary

            d: a tuple which determines which diagram is being considered
            n: the normal of the wall whose multiplicity is being considered
        """
        #first, the inputs are switched if decreasing
        if d[0]>d[1]:
            d=(d[1],d[0]);
            n=(n[1],n[0]);
        #checks if the desired diagram exists, and if not, creates it
        if not(d in self.diagrams):
            self.diagrams[d]=ScatteringDiagram([SDWall((0,1),point=(0,-random())),SDWall((0,1),d=d[1]-1),SDWall((1,0),d=d[0])]);
            if verbose:
                print "Model "+str(d)+" created";
        #checks if the desired diagram has high enough order to produce the desired multiplicity
        while self.diagrams[d].order<n[0]+n[1]:
            if verbose:
                print "Attempting to improve model "+str(d)+" to order "+str(self.diagrams[d].order+1);
            self.diagrams[d].improve(verbose=verbose);
            if verbose:
                print "Model "+str(d)+" improved to order "+str(self.diagrams[d].order);
        #returns the desired multiplicity
        if n in self.diagrams[d].multiplicities:
            return self.diagrams[d].multiplicities[n];
        else:
            return 0;

    def mtable(self,d,ord,verbose=False):
        """
            mtable() prints a table of the multiplicities of the walls in the model scattering diagram d, up to order ord.

            d: a tuple which determines which diagram is being considered
            ord: the minimum desired order of the diagram.  If the current order is larger than ord, then the larger order is used.
        """
        self.multiplicity(d,(1,ord-1),verbose=verbose);
        for i in range(ord+1):
            print [self.multiplicity(d,(ord-i,j)) for j in range(0,i+1)];

    def GHKKTerm(self,d,n,denom=1):
        """
            GHKKTerm() computes the scattering term (in the sense of GHKK) in the model scattering diagram d, on the ray with normal n.

            d: a tuple which determines which diagram is being considered
            n: the normal of the wall whose GHKK term is being considered
        """
        R.<x>=PowerSeriesRing(ZZ)
        prec=floor((self.diagrams[d].order)/(n[0]+n[1]))+1
        L=[(1+x^i+O(x^prec))^(self.multiplicity(d,(i*n[0],i*n[1]))/denom) for i in range(prec)];
        return reduce(lambda a,b:a*b,L,1)

DefaultTable=SDTable();

class SDWall:
    """
        SDWall creates an object which encodes a wall inside a 2-dimensional scattering diagram with B=J.

        n: A tuple of integers normal to the wall
        source: None if the wall is a line, or a tuple describing the point of origin of the wall if it is a ray
        multi: An integer counting how many copies of the wall are being described

        Examples:
        sage: SDWall((0,1))
        A line through the point (0, 0) with normal vector (0, 1)
        sage: SDWall((1,1),point=(0,-1),d=3)
        A line through the point (3, 0.600000000000000) with normal vector (1, 1) and multiplicity 3
    """
    def __init__(self,n,point=(0,0),d=1,source=None):
        self.source=source;
        self.is_ray=(source!=None);
        if self.is_ray:
            self.point=source.point;
        else:
            self.point=point;
        self.n=n;
        self.d=d;
        #gcd stores the gcd of the coordinates of the normal covector n
        self.gcd=gcd(n[0],n[1]);
        #order stores the sum of the coordinates of the normal covector n
        self.order=n[0]+n[1];
        #offset is the value of the normal covector on the source point; it is used by collision computations
        self.offset=n[0]*point[0]+n[1]*point[1]+(10^(-12))*random();
        #if the gcd>1, the support of the wall is perturbed by a small amount.  The magnitude of this perturbation can be controlled with the value of self.perturb.
        self.perturb=10^(-6);
        if self.gcd==1:
            self.nreal=self.n;
        else:
            self.theta=uniform(0,self.perturb);
            self.nreal=(float(cos(self.theta)*n[0]-sin(self.theta)*n[1]),float(sin(self.theta)*n[0]+cos(self.theta)*n[1]));

    def __repr__(self):
        if self.is_ray:
            output = "An outgoing ray starting at "+str(self.point)+" with normal vector "+ str(self.n)
        else:
            output = "A line through the point "+str(self.point)+" with normal vector "+ str(self.n)
        if self.d!=1:
            output += " and multiplicity "+str(self.d);
        return output

    def draw(self,xmin,xmax,ymin,ymax):
        """
            draw() returns a graphics object depicting the wall in the specified range
        """
        wallcolor=(1-1/float(self.d),0,1/float(self.d));
        if self.is_ray:
            if xmin>self.point[0] or xmax<self.point[0] or ymin>self.point[1] or ymax<self.point[1]:
                return None;
            else:
                if self.n[0]==0:
                    t= (xmax-self.point[0])/self.n[1];
                elif self.n[1]==0:
                    t=(-ymin+self.point[1])/self.n[0];
                else:
                    t=min((xmax-self.point[0])/self.n[1],(-ymin+self.point[1])/self.n[0]);
                return line([self.point,(self.point[0]+t*self.n[1],self.point[1]-t*self.n[0])],rgbcolor=wallcolor);
        else:
            if self.n[0]==0:
                t1= (xmin-self.point[0])/self.n[1];
                t2= (xmax-self.point[0])/self.n[1];
            elif self.n[1]==0:
                t1=(-ymin+self.point[1])/self.n[0];
                t2=(-ymax+self.point[1])/self.n[0];
            else:
                t1=min((xmin-self.point[0])/self.n[1],(-ymax+self.point[1])/self.n[0]);
                t2=min((xmax-self.point[0])/self.n[1],(-ymin+self.point[1])/self.n[0]);
            return line([(self.point[0]+t1*self.n[1],self.point[1]-t1*self.n[0]),(self.point[0]+t2*self.n[1],self.point[1]-t2*self.n[0])],rgbcolor=wallcolor);

    def collide(self,wall,table=DefaultTable):
        """
            collide() inputs an SDWall, outputs a new SDVertex at the common intersection, or None there is no such intersection (or the walls are parallel)
        """
        det=self.n[0]*wall.n[1]-self.n[1]*wall.n [0];
        detreal=self.nreal[0]*wall.nreal[1]-self.nreal[1]*wall.nreal[0];
        #to prevent numerical error from creating incorrect collisions, we require that the walls intersect by a minimum amount eps.
        eps=10^(-12);
        if det>0:
            #Case: self wall is clockwise from input wall
            if ((self.point[0]-wall.point[0])*self.nreal[0]+(self.point[1]-wall.point[1])*self.nreal[1]>eps or not(wall.is_ray)) and ((self.point[0]-wall.point[0])*wall.nreal[0]+(self.point[1]-wall.point[1])*wall.nreal[1]>eps or not(self.is_ray)):
                intersection=( (wall.nreal[1]*self.offset-self.nreal[1]*wall.offset)/detreal,(-wall.nreal[0]*self.offset+self.nreal[0]*wall.offset)/detreal);
                return SDVertex(intersection,self,wall,table=table);
            else:
                return None;
        elif det<0:
            #Case: self wall is counterclockwise from input wall
            if ((self.point[0]-wall.point[0])*self.nreal[0]+(self.point[1]-wall.point[1])*self.nreal[1]<-eps or not(wall.is_ray)) and ((self.point[0]-wall.point[0])*wall.nreal[0]+(self.point[1]-wall.point[1])*wall.nreal[1]<-eps or not(self.is_ray)):
                intersection=( (wall.nreal[1]*self.offset-self.nreal[1]*wall.offset)/detreal,(-wall.nreal[0]*self.offset+self.nreal[0]*wall.offset)/detreal);
                return SDVertex(intersection,wall,self,table=table);
            else:
                return None;
        else:
            return None;

class SDVertex:
    """
        SDVertex(point,w1,w2) creates an object which encodes the collision vertex betweent two SDWalls.  Intended to be created by SDWall.collide(); not intended for external creation.

        point: a tuple denoting the location of the collision.
        w1,w2: Two SDWalls encoding the walls which define the collision.
    """
    def __init__(self,point,w1,w2,table=DefaultTable):
        self.point=point;
        #switches order of defining rays, to ensure cross product is positive
        self.det=w1.n[0]*w2.n[1]-w1.n[1]*w2.n[0];
        if self.det<0:
            (w1,w2)=(w2,w1);
            self.det=-self.det;
        self.w1=w1;
        self.w2=w2;
        self.table=table;
        #self.exponents is the 2-tuple which describes the exponents in the inflation of the vertex
        self.exponents=(self.det*self.w1.d/self.w1.gcd,self.det*self.w2.d/self.w2.gcd);
        #self.ordergcd is is the gcd of the orders of n1 and n2
        self.ordergcd=gcd(self.w1.order,self.w2.order);
        #nexta is a list of elements of the form (a1,a2,lambda), such that a1*w1.n+a2*w2.n is the first wall of order lambda produced, and all the other walls with the same lambda are of the form (a1,a2)+i*aincrement.
        self.nexta =[(i,1,i*self.w1.order+self.w2.order) for i in range(1,(self.w2.order)/self.ordergcd+1)];
        self.nextorder = self.nexta[0][0]*self.w1.order+self.nexta[0][1]*self.w2.order;
        self.aincrement=(self.w2.order/self.ordergcd,-self.w1.order/self.ordergcd);

    def __repr__(self):
        return "A vertex at point "+str(self.point);

    def improve(self,verbose=False):
        """
            improve() increases the order of the vertex, and returns a list of walls required to increase the order
        """
        if self.nextorder!=100000:
            newwalls=[],table=self.table;
            if self.nextorder==(self.w1.order+self.w2.order):
            #The first time a vertex is improved, only a single wall is added in a predictable way.  This doesn't use the DT table, which eliminates the need for unnecessary recursions.
                newn=(self.w1.n[0]+self.w2.n[0],self.w1.n[1]+self.w2.n[1])
                newwalls = [SDWall(newn,point=self.point,d=(self.w1.d*self.w2.d*self.det)*gcd(newn[0],newn[1])/(self.w1.gcd*self.w2.gcd),source=self)];
            else:
            #Otherwise, the vertex looks up which walls need to be added on the DT table.
                for i in range(ceil(self.nexta[0][1]/float(-self.aincrement[1]))):
                #computes relative and absolute exponent of the new wall
                    currenta=(self.nexta[0][0]+i*self.aincrement[0],self.nexta[0][1]+i*self.aincrement[1]);
                    currentn=(currenta[0]*self.w1.n[0]+currenta[1]*self.w2.n[0],currenta[0]*self.w1.n[1]+currenta[1]*self.w2.n[1]);
                    #looks up the multiplicity of the newly spawned wall
                    multi=(self.table.multiplicity(self.exponents,currenta,verbose=verbose)*gcd(currentn[0],currentn[1]))/(self.det*gcd(currenta[0],currenta[1]));
                    #spawns a wall if needed
                    if multi!=0:
                        newwalls.append(SDWall(currentn,point=self.point,d=multi,source=self));
            if self.exponents==(1,1):
                self.nexta=[];
                self.nextorder=100000;
            else:
                #removes the first entry in nexta, and generates a new entry with second coordinate 1 higher
                a=self.nexta.pop(0);
                a=(a[0],a[1]+1,a[2]+self.w2.order);
                #inserts the new entry so that they are ordered in lambda
                length=len(self.nexta);
                i=0;
                for i in range(1,len(self.nexta)+1):
                    if self.nexta[-i][2]<a[2]:
                        break
                    i=i+1
                self.nexta.insert(length-i+1,a);
                self.nextorder=self.nexta[0][2];
            return newwalls;

    def draw(self):
        """
            draw() returns a graphics object depicting the vertex, which is blue if the vertex is consistent and red otherwise
        """
        if self.nextorder>(100000-10):
            return point(self.point,marker='o',markeredgecolor='blue');
        else:
            return point(self.point,marker='o',markeredgecolor='red');

class ScatteringDiagram():
    """
        ScatteringDiagram(walls) creates an object which collects several walls into a scattering diagram.

        walls: a list of SDWalls comprising the scattering diagram

        Example:
        sage: ScatteringDiagram([SDWall((1,0)),SDWall((0,1)),SDWall((0,1),point=(0,-1))])
        A scattering diagram in R^2 with 3 walls and 2 vertices
    """

    def __init__(self,walls,table=DefaultTable):
        self.walls = walls;
        self.table = table;
        #the initial set of vertices are generated from the rays via pair-wise collision detection
        self.vertices =[];
        for i in range(0,len(self.walls)-1):
            for j in range(i+1,len(self.walls)):
                vert=self.walls[i].collide(self.walls[j],table=self.table);
                if vert!=None:
                    self.vertices.append(vert);
        #the order of the scattering diagrams is the minimum of the order of the vertices
        self.order = min([vert.nextorder-1 for vert in self.vertices]);
        #multiplicities is a dictionary which counts how many walls of type n the scattering diagram currently has
        self.multiplicities={};
        for wall in self.walls:
            if wall.n in self.multiplicities:
                self.multiplicities[wall.n]+=wall.d;
            else:
                self.multiplicities[wall.n]=wall.d;

    def __repr__(self):
        return "A scattering diagram in R^2 with "+str(len(self.walls))+" walls and "+str(len(self.vertices))+" vertices"

    def __repr__(self):
        return "A scattering diagram in R^2 with "+str(len(self.walls))+" walls and "+str(len(self.vertices))+" vertices"

    def draw(self):
        """
           """
            draw() produces a plot with all of the consituent walls and vertices, large enough to fit all of the vertices
        """
        """
        #the lower right corner of the plot will be right and below each of the vertices
        xmin=min([vertex.point[0]-1 for vertex in self.vertices]);
        xmax=max([vertex.point[0]+1 for vertex in self.vertices]);
        ymin=min([vertex.point[1]-1 for vertex in self.vertices]);
        ymax=max([vertex.point[1]+1 for vertex in self.vertices]);
        return plot([vertex.draw() for vertex in self.vertices]+[wall.draw(xmin,xmax,ymin,ymax) for wall in self.walls],aspect_ratio=1,axes=False);

    def improve(self,verbose=False,draw=False):
        """
           """
            improve() attempts to increases the order of the scattering diagram by 1
        """
        """
        if self.order!=100000:
            for vertex in self.vertices:
                #use vertex.improve() to find rays that must be added at that vertex
                if vertex.nextorder==self.order+1:
                    newwalls=vertex.improve(verbose=verbose);
                    #check for collisions between new rays and old rays
                    for wall in newwalls:
                        for oldwall in self.walls:
                            vert=oldwall.collide(wall,table=self.table);
                            if vert !=None:
                                self.vertices.append(vert);
                    #add the new rays
                    self.walls.extend(newwalls);
                    #updates multiplicities
                    for wall in newwalls:
                        if wall.n in self.multiplicities:
                            self.multiplicities[wall.n]+=wall.d;
                        else:
                            self.multiplicities[wall.n]=wall.d;
            self.order=min([vert.nextorder for vert in self.vertices])-1;
            for v1 in self.vertices:
                for v2 in self.vertices:
                    if (v1.point==v2.point) and (v1!=v2):
                        print 'WARNING: A non-generic collision has occured at ' +str(v1.point)
        if draw:
            return self.draw()
︡ba133be6-cc70-442d-861b-f4645aa7067e︡
︠d0fc569a-f4eb-45b6-a5eb-25c5182de982︠
SDWall((0,1))
SDWall((1,1),point=(3,.6),d=3)
︡9116e0f7-411e-4dc4-9910-fcf4dc5e3e0a︡{"stdout":"A line through the point (0, 0) with normal vector (0, 1)\n"}︡{"stdout":"A line through the point (3, 0.600000000000000) with normal vector (1, 1) and multiplicity 3\n"}︡
︠5365fc6c-bdc5-43a2-ac87-e5197c267f88︠
D=ScatteringDiagram([SDWall((1,0)),SDWall((0,1)),SDWall((0,1),point=(0,-1))])
D
D.draw()
︡0c227343-e754-4e3c-9141-85812f0cfd8c︡{"stdout":"A scattering diagram in R^2 with 3 walls and 2 vertices\n"}︡{"once":false,"file":{"show":true,"uuid":"ccebc98a-a78e-4a82-8cde-2103c6a26462","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_E9mcmO.svg"}}︡{"html":"<div align='center'></div>"}︡
︠5c3759dc-7e1a-487e-a0cc-feb42dd83569︠
for i in range(2):
    D.improve()
    D.draw()
︡4a232c23-5bec-4ec8-a6c3-c5dde9f82239︡{"once":false,"file":{"show":true,"uuid":"21dfe1fe-cbba-473b-ad14-adfd6e0e5b3d","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp__CbRu6.svg"}}︡{"html":"<div align='center'></div>"}︡{"once":false,"file":{"show":true,"uuid":"9f2f94ae-c172-498d-b8ea-832d9387c307","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_U6emHO.svg"}}︡{"html":"<div align='center'></div>"}︡
︠64be54dc-f3ee-4c04-bc43-72bfbf132da7︠
D=ScatteringDiagram([SDWall((1,0)),SDWall((0,1)),SDWall((0,1),point=(0,-1)),SDWall((1,0),point=(2,0))])
D.draw()
for i in range(4):
    D.improve(draw=True)

︡3624b8fb-7a9b-490e-a272-40dbe01d0999︡{"once":false,"file":{"show":true,"uuid":"5b46d391-b817-4b74-996b-16a1dc94f019","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_OLgRi4.svg"}}︡{"html":"<div align='center'></div>"}︡{"once":false,"file":{"show":true,"uuid":"79806051-defd-49cf-8cb8-bf3d5ebb188a","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_PSSgKU.svg"}}︡{"html":"<div align='center'></div>"}︡{"once":false,"file":{"show":true,"uuid":"f191b08e-96de-4ea2-aae5-19cbb073cc88","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_b7dCx0.svg"}}︡{"html":"<div align='center'></div>"}︡{"once":false,"file":{"show":true,"uuid":"89ad2c51-5150-470b-aa10-ee3d120e7715","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_dZ0DSl.svg"}}︡{"html":"<div align='center'></div>"}︡{"once":false,"file":{"show":true,"uuid":"f7816095-c272-4469-bf5a-f7fa8d7f1c1a","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_8KVelh.svg"}}︡{"html":"<div align='center'></div>"}︡
︠20f39f1c-db12-4010-a2df-5088f9779bf0︠
DefaultTable.diagrams[(2,2)].draw()
︡726b32a6-3fd0-4e31-8e5f-e9f6d085af27︡{"once":false,"file":{"show":true,"uuid":"758cdd5d-d3d4-4389-bb13-636ef4c74581","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp__FfLt0.svg"}}︡{"html":"<div align='center'></div>"}︡
︠8c3f5ad1-b105-48de-9803-26b5d4ddc882︠
DefaultTable.mtable((2,2),16,verbose=True)
︡3d532590-b877-44fb-809d-796ed196e347︡{"stdout":"Attempting to improve model (2, 2) to order 4\nModel (2, 2) improved to order 4\nAttempting to improve model (2, 2) to order 5\nModel (2, 2) improved to order 5\nAttempting to improve model (2, 2) to order 6\nModel (2, 2) improved to order 6\nAttempting to improve model (2, 2) to order 7\nModel (2, 2) improved to order 7\nAttempting to improve model (2, 2) to order 8\nModel (2, 2) improved to order 8\nAttempting to improve model (2, 2) to order 9\nModel (2, 2) improved to order 9\nAttempting to improve model (2, 2) to order 10\nModel (2, 2) improved to order 10\nAttempting to improve model (2, 2) to order 11\nModel (2, 2) improved to order 11\nAttempting to improve model (2, 2) to order 12\nModel (2, 2) improved to order 12\nAttempting to improve model (2, 2) to order 13\nModel (2, 2) improved to order 13\nAttempting to improve model (2, 2) to order 14\nModel (2, 2) improved to order 14\nAttempting to improve model (2, 2) to order 15\nModel (2, 2) improved to order 15\nAttempting to improve model (2, 2) to order 16\nModel (2, 2) improved to order 16\n[0]\n[0, 0]\n[0, 0, 0]\n[0, 0, 0, 0]\n[0, 0, 0, 0, 0]\n[0, 0, 0, 0, 0, 0]\n[0, 0, 0, 0, 0, 0, 0]\n[0, 0, 0, 0, 0, 0, 0, 0]\n[0, 0, 0, 0, 0, 0, 0, 2, 4]\n[0, 0, 0, 0, 0, 0, 2, 0, 2, 0]\n[0, 0, 0, 0, 0, 2, 0, 2, 0, 0, 0]\n[0, 0, 0, 0, 2, 0, 2, 0, 0, 0, 0, 0]\n[0, 0, 0, 2, 4, 2, 0, 0, 0, 0, 0, 0, 0]\n[0, 0, 2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0]\n[0, 2, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]\n[2, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]\n[0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]\n"}︡
︠31c96504-b470-4261-b701-c8f514a4e248︠
D=ScatteringDiagram([SDWall((1,0)),SDWall((0,1),point=(0,-1)),SDWall((0,1),point=(0,-3)),SDWall((0,1)),SDWall((1,0),point=(2.23,0)),SDWall((1,0),point=(5.3,0))])
D.draw()
for i in range(3):
    D.improve(verbose=True)
D.draw()
︡0f5d5c8e-bf72-4c53-8efb-ad245c1bcd67︡{"once":false,"file":{"show":true,"uuid":"e8182f5a-c230-4cab-b85b-96a269eee9da","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_faClgH.svg"}}︡{"html":"<div align='center'></div>"}︡{"once":false,"file":{"show":true,"uuid":"c4f76462-dbc0-4599-9239-12da01987ba1","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_U9UHqL.svg"}}︡{"html":"<div align='center'></div>"}︡
︠f235ba42-418f-439f-be7f-6310ec80f223︠
DefaultTable.mtable((1,5),10)
︡3d26d7ba-a042-4113-8cd0-afe843032d60︡{"stdout":"[0]"}︡{"stdout":"\n[0, 0]\n[0, 0, 0]\n[0, 0, 0, 0]\n[0, 0, 0, 0, 0]\n[0, 0, 0, 0, 0, 0]\n[0, 0, 0, 0, 0, 1, 20]\n[0, 0, 0, 0, 5, 27, 45, 85]\n[0, 0, 0, 10, 20, 27, 20, 10, 0]\n[1, 5, 10, 10, 5, 1, 0, 0, 0, 0]\n[0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0]\n"}︡
︠31974679-228c-4a18-95ad-6857b5f93197︠
DefaultTable.mtable((3,3),8)
︡96bf20b3-3930-499c-8a40-767e6bed9a32︡{"stdout":"[0]"}︡{"stdout":"\n[0, 0]\n[0, 0, 0]\n[0, 0, 9, 204]\n[0, 0, 36, 204, 1044]\n[0, 3, 39, 162, 204, 204]\n[0, 9, 36, 39, 36, 9, 0]\n[3, 9, 9, 3, 0, 0, 0, 0]\n[0, 3, 0, 0, 0, 0, 0, 0, 0]\n"}︡
︠dbaebb57-d70d-4081-ace3-f58da2a3a722︠
DefaultTable.diagrams[(3,3)].draw()
︡937d99d1-0a57-4043-a037-1be0b12d81bd︡{"once":false,"file":{"show":true,"uuid":"6a17893e-daa1-4ad1-8c0c-82aedaefdba1","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_aWaE0q.svg"}}︡{"html":"<div align='center'></div>"}︡
︠4f894432-61d0-4459-bd9b-37070ad06f6b︠
DefaultTable.GHKKTerm((3,3),(1,1),denom=9)
︡deecb9d9-fefe-4c72-9fee-5a6d8f94e55d︡{"stdout":"1 + x + 4*x^2 + 22*x^3 + 140*x^4 + O(x^5)\n"}︡
︠c8711c4b-0309-431e-a503-28b666fcac91︠
D=ScatteringDiagram([SDWall((1,0)),SDWall((0,1)),SDWall((1,0),point=(2,0)),SDWall((0,1),point=(0,1))])
D.draw()
for i in range(5):
    D.improve(verbose=True);
    D.draw()
︡f852a291-c3b7-40bd-92d9-6e48419ff4ad︡{"once":false,"file":{"show":true,"uuid":"e5dd2f65-bdd5-4507-9ba8-fa72dbcc34d6","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_8XZko0.svg"}}︡{"html":"<div align='center'></div>"}︡{"once":false,"file":{"show":true,"uuid":"89cbf6b4-be55-40e8-bfa3-1a279adb444c","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_y4gFNa.svg"}}︡{"html":"<div align='center'></div>"}︡{"once":false,"file":{"show":true,"uuid":"75152b4f-322d-4b1d-ae7a-b49b4a70f752","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_1fvciA.svg"}}︡{"html":"<div align='center'></div>"}︡{"once":false,"file":{"show":true,"uuid":"e8f87c90-6b14-4858-aa15-eddbd7c4c427","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_WuYfwp.svg"}}︡{"html":"<div align='center'></div>"}︡{"once":false,"file":{"show":true,"uuid":"24b6f7d2-6dfe-4c0a-8c77-1ad483d4b5e4","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_FPIevZ.svg"}}︡{"html":"<div align='center'></div>"}︡{"once":false,"file":{"show":true,"uuid":"24b6f7d2-6dfe-4c0a-8c77-1ad483d4b5e4","filename":"/projects/a377892b-9b6e-4a10-a2e1-c526b21c2e94/.sage/temp/compute1-us/9698/tmp_jpFoeY.svg"}}︡{"html":"<div align='center'></div>"}︡
︠333ea194-a328-4980-9983-87b32c4b9c1c︠









