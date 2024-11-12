import random
import time

n=[5,10,15]
p=[10,15,20]
d_moy=[]

def trouver_cout(r,retour,cout):
    for i in retour:
        if(i[1]==r):
            return cout[i[0]]

def trouver_i(r,retour):
    for i in retour:
        if(i[1]==r):
            return i[0]

def sac_a_dos(u,w,p):
    rapports=[]
    retour=[]
    sol=[]
    for i in range(len(u)):
        sol+=[0]
    for i in range(len(u)):
        rapports+=[u[i]/w[i]]
        retour+=[(i,u[i]/w[i])]
    rapports.sort()
    i=-1
    s=0
    while(i>=-len(rapports) and s<p):
        dernier=trouver_cout(rapports[i],retour,cout)
        index=trouver_i(rapports[i],retour)
        sol[index]=1
        s+=dernier
        i-=1
    i+=1
    s-=dernier
    coef=(p-s)/dernier
    sol[index]==coef
    return sol

for i in n:
    for j in p:
        nb_iteration+=1
        durees=[]
        moy=0
        for inst in range(10):
            cout=[]
            utilite=[]
            for c1 in range(i):
                for c2 in range(j):
                    cout+=[random.randint(1,100)]
                    utilite+=[random.randint(1,100)]
            cpt=0
            for c in cout:
                cpt+=c
            poids=cpt/2
            t1=time.time()
            sol=sac_a_dos(cout,utilite,poids);
            t2=time.time()
            durees+=[t2-t1]
        for d in durees:
            moy+=d
        moy=moy/len(durees)
        d_moy+=[moy]
print(d_moy)