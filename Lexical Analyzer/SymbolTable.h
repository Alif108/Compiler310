#include<bits/stdc++.h>
#include<fstream>

using namespace std;


class SymbolInfo
{
	string Name;
	string Type;
	SymbolInfo* next;

public:

    SymbolInfo(string name, string type)
    {
        this->Name = name;
        this->Type = type;
        next = NULL;
    }

    string getName()
    {
        return Name;
    }

    string getType()
    {
        return Type;
    }

    void setNext(SymbolInfo* s)
    {
        next = s;
    }

    SymbolInfo* getNext()
    {
        return this->next;
    }

//    ~SymbolInfo()
//    {
//        delete next;
//    }
};


//---------SymbolInfo ends here-------------


class ScopeTable
{
    int bucket;
    SymbolInfo **table;
    ScopeTable* parentScope;
    string id;
    int child;
    string parent_id;

public:
    ScopeTable(int x);
    bool InsertSymbol(string name, string type, ofstream &outFile);
    SymbolInfo* LookupSymbol(string name);
    bool Delete(string name);
    void Print(ofstream &outFile);
    bool Search(string name);
    void setParentScope(ScopeTable* x);
    ScopeTable* getParentScope();
    void incChild();
    void setId(int x, bool global);
    void setParentId(string x);
    string getId();
    string getParentId();
    int getChild();
    ~ScopeTable();


    int hashFunction(string name)
    {
        int sum = 0;

        for(int i=0; i<name.length(); i++)
        {
            sum += int(name[i]);
            //cout<<sum<<endl;
        }
        return (sum % bucket);
    }
};

ScopeTable::ScopeTable(int x)
{
    this->bucket = x;
    table = new SymbolInfo*[bucket];
    for(int i=0; i<bucket; i++)
        table[i] = NULL;

    parentScope = NULL;
    child = 0;
}

void ScopeTable::setParentScope(ScopeTable* x)
{
    parentScope = x;
}

ScopeTable* ScopeTable::getParentScope()
{
    return this->parentScope;
}

bool ScopeTable::Search(string name)
{
    int idx = hashFunction(name);

    SymbolInfo* temp = table[idx];

    if(temp == NULL)
    {
        return false;
    }

    else if(temp->getName().compare(name) == 0)
        return true;

    else
    {
        while(temp->getNext() != NULL)
        {
            temp = temp->getNext();
            if(temp->getName().compare(name) == 0)
                return true;
        }
    }

    return false;
}

void ScopeTable::setId(int x, bool global)
{
    string current_id;
    stringstream ss;
    ss<<x;
    ss>>current_id;

    if(!global)
    {
        id = parent_id + "." + current_id;
    }
    else
        id = current_id;
}

void ScopeTable::incChild()
{
    child++;
}

int ScopeTable::getChild()
{
    return child;
}

void ScopeTable::setParentId(string x)
{
    parent_id = x;
}

string ScopeTable::getId()
{
    return id;
}

string ScopeTable::getParentId()
{
    return parent_id;
}

bool ScopeTable::InsertSymbol(string name, string type, ofstream &outFile)
{

    int idx = hashFunction(name);
    int chain = 0;

    if(!Search(name))
    {
        SymbolInfo *symbol = new SymbolInfo(name, type);

        if(table[idx] == NULL)
        {
            table[idx] = symbol;
            //cout<<"Inserted in Scopetable # "<<this->id<<" at position "<< idx<<", "<<chain<<endl<<endl;
            return true;
        }

        else
        {
            SymbolInfo* temp = table[idx];

            while(temp->getNext() != NULL)
            {
                temp = temp->getNext();
                chain++;
            }
            chain++;
            temp->setNext(symbol);
            //cout<<"Inserted in Scopetable # "<<this->id<<" at position "<< idx<<", "<<chain<<endl<<endl;
            return true;
        }
   }
    else
    {
       outFile<<name<<" already exists in the current ScopeTable"<<endl<<endl;
       return false;
    }
}

SymbolInfo* ScopeTable::LookupSymbol(string name)
{
    int idx = hashFunction(name);
    int chain = 0;

    SymbolInfo* temp = table[idx];

    if(temp == NULL)
        return NULL;

    else if(temp->getName().compare(name) == 0)
    {
        //cout<<"Found in ScopeTable # "<<this->id<<" at position "<<idx<<", "<<chain<<endl<<endl;
        //outFile<<"Found in ScopeTable # "<<this->id<<" at position "<<idx<<", "<<chain<<endl<<endl;
        return temp;
    }

    else
    {
        while(temp->getNext() != NULL)
        {
            temp = temp->getNext();
            chain++;

            if(temp->getName().compare(name) == 0)
            {
                //cout<<"Found in ScopeTable # "<<this->id<<" at position "<<idx<<", "<<chain<<endl<<endl;
                //outFile<<"Found in ScopeTable # "<<this->id<<" at position "<<idx<<", "<<chain<<endl<<endl;
                return temp;
            }
        }
    }
    return NULL;
}

bool ScopeTable::Delete(string name)
{
    if(Search(name))
    {
        int idx = hashFunction(name);
        int chain = 0;

        SymbolInfo* temp = table[idx];

        if(temp->getName().compare(name) == 0)
        {
            temp = temp->getNext();
            table[idx] = temp;
            //cout<<"Deleted Entry "<<idx<<", "<<chain<<" from current ScopeTable"<<endl<<endl;
            //outFile<<"Deleted Entry "<<idx<<", "<<chain<<" from current ScopeTable"<<endl<<endl;
            return true;
        }
        else
        {
            while(temp->getNext() != NULL)
            {
                chain++;
                if(temp->getNext()->getName().compare(name) == 0)
                {
                    temp->setNext(temp->getNext()->getNext());
                    //cout<<"Deleted Entry "<<idx<<", "<<chain<<" from current ScopeTable"<<endl<<endl;
                    //outFile<<"Deleted Entry "<<idx<<", "<<chain<<" from current ScopeTable"<<endl<<endl;
                    return true;
                }
                temp->getNext();
            }
        }
    }
    else
    {
        cout<<"Not Found in current ScopeTable; "<<"Delete Unsuccessful"<<endl<<endl;
        //outFile<<"Not Found in current ScopeTable; "<<"Delete Unsuccessful"<<endl<<endl;
        return false;
    }
    return false;
}

void ScopeTable::Print(ofstream &outFile)
{
    SymbolInfo* temp;
	
    outFile<<"Scopetable # "<<this->id<<endl;

    for(int i=0; i<bucket; i++)
    {
        temp = table[i];

        //cout<<i<<" --> ";

        if(temp != NULL)
        {

            outFile<<i<<" --> ";
            outFile<<"<"<<temp->getName()<<" : "<<temp->getType()<<"> ";
            
            while(temp->getNext() != NULL)
            {
                temp = temp->getNext();
                outFile<<"<"<<temp->getName()<<" : "<<temp->getType()<<"> ";
            }
            outFile<<endl;
        }
    }
    //cout<<endl;
    outFile<<endl;
}

ScopeTable::~ScopeTable()
{
    if(table)
        delete[] table;
    table = 0;

    delete parentScope;
}


//-------------ScopeTable ends here--------------


class SymbolTable
{
    int bucket;
    //list<ScopeTable> table;
    ScopeTable* current;
    //ofstream outFile;

public:
    SymbolTable(int bucket);
    void EnterScope();
    void ExitScope();
    bool Insert(string name, string type, ofstream &outFile);
    bool Remove(string name);
    SymbolInfo* Lookup(string name);
    void printCurrentScopeTable(ofstream &outFile);
    void printAllScopeTable(ofstream &outFile);
    void printCurrentScopeId();
    ~SymbolTable();
};

SymbolTable::SymbolTable(int buck)
{
    this->bucket = buck;
    current = new ScopeTable(bucket);
    current->setId(1, true);
    //outFile.open("log.txt", ios_base::app);
    //cout<<"ScopeTable # 1 created"<<endl<<endl;
    //outFile<<"ScopeTable # 1 created"<<endl<<endl;
}

void SymbolTable::EnterScope()
{
    ScopeTable* temp = new ScopeTable(bucket);
    current->incChild();
    temp->setParentScope(current);
    temp->setParentId(current->getId());                	//child's parent id is parent's current id
    temp->setId(current->getChild(), false);                   //child's id is parent's child no.
    current = temp;

    //cout<<"New Scopetable with id ";
    //outFile<<"New Scopetable with id ";
    //printCurrentScopeId();
    //cout<<" created"<<endl<<endl;
    //outFile<<" created"<<endl<<endl;
}

void SymbolTable::ExitScope()
{
    ScopeTable* temp = current;
    temp = temp->getParentScope();

    //cout<<"ScopeTable with id "<<current->getId()<<" exited"<<endl<<endl;
    //outFile<<"ScopeTable with id "<<current->getId()<<" exited"<<endl<<endl;

    current = temp;
    temp = NULL;
}

bool SymbolTable::Insert(string name, string type, ofstream &outFile)
{
	
    bool x = current->InsertSymbol(name, type, outFile);
    
    if(x)
    {
    	printAllScopeTable(outFile);
    }
    
    return x;
}

bool SymbolTable::Remove(string name)
{
    return current->Delete(name);
}

SymbolInfo* SymbolTable::Lookup(string name)
{
    ScopeTable* temp = current;

    if(temp->Search(name))
    {
        return temp->LookupSymbol(name);
    }

    else
    {
        while(temp->getParentScope() != NULL)
        {
            temp = temp->getParentScope();
            if(temp->Search(name))
            {
                return temp->LookupSymbol(name);
            }
        }
    }
    //cout<<"Symbol Not Found"<<endl<<endl;
    //outFile<<"Symbol Not Found"<<endl<<endl;
    return NULL;
}

void SymbolTable::printCurrentScopeTable(ofstream &outFile)
{
    current->Print(outFile);
}

void SymbolTable::printAllScopeTable(ofstream &outFile)
{
    ScopeTable* temp = current;

    temp->Print(outFile);

    while(temp->getParentScope() != NULL)
    {
        temp = temp->getParentScope();
        temp->Print(outFile);
    }
}

void SymbolTable::printCurrentScopeId()
{
    cout<<current->getId();
    //outFile<<current->getId();
}

SymbolTable::~SymbolTable()
{
    delete current;
}

//--------------SymbolTable ends here---------------

//int main()
//{
//    ifstream inFile;
//    inFile.open("input.txt");

//    ofstream outFile;
//    outFile.open("output.txt");

//    if(inFile.fail())
//    {
//        cerr<<"Couldn't Open Input File";
//        exit(1);
//    }
//    if(outFile.fail())
//    {
//        cerr<<"Couldn't Open Output File";
//        exit(1);
//    }

//    int n;
//    char a,b;
//    string name, type;

//    inFile>>n;

//    SymbolTable s(n, outFile);

//    while(!inFile.eof())
//    {
//        inFile>>a;
//        if(a == 'I')
//        {
//            inFile>>name>>type;
//            s.Insert(name, type, outFile);
//        }
//        else if(a == 'S')
//        {
//            s.EnterScope(outFile);
//        }
//        else if(a == 'P')
//        {
//            inFile>>b;
//            if(b == 'A')
//                s.printAllScopeTable(outFile);
//            else
//                s.printCurrentScopeTable(outFile);
//        }
//        else if(a == 'L')
//        {
//            inFile>>name;
//            s.Lookup(name, outFile);
//        }
//        else if(a == 'D')
//        {
//            inFile>>name;
//            s.Remove(name, outFile);
//        }
//        else if(a == 'E')
//        {
//            s.ExitScope(outFile);
//        }
//        else
//        {
//            cout<<"Action not available"<<endl;
//        }
//    }

//    return 0;
//}
