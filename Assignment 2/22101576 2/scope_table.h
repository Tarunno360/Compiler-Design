#include "symbol_info.h"

class scope_table
{
private:
    int bucket_count;
    int unique_id;
    scope_table *parent_scope = NULL;
    vector<list<symbol_info *>> table;

    int hash_function(string name)
    {
        int hash = 0;
        for (char ch : name)
        {
            hash+=ch;
        }
        return hash % bucket_count;
        // write your hash function here
    }

public:
    scope_table(){
        bucket_count = 0;
        unique_id = 0;
        parent_scope = NULL;
    };
    scope_table(int bucket_count, int unique_id, scope_table *parent_scope){
        this->bucket_count = bucket_count;
        this->unique_id = unique_id;
        this->parent_scope = parent_scope;
        table.resize(bucket_count);
    };
    scope_table *get_parent_scope()
    {
        return parent_scope;
    }
    int get_unique_id(){
        return unique_id;
    }
    symbol_info *lookup_in_scope(symbol_info* symbol)
    {
        string hash_name = symbol->getname();
        int index_number = hash_function(hash_name);
        for(symbol_info* sym : table[index_number]){
            if(sym->getname() == hash_name){
                return sym; // found
            }
        }
        return nullptr;
    }
    bool insert_in_scope(symbol_info* symbol)
    {
        if(lookup_in_scope(symbol) != nullptr){
            return false;
        }
        int index_number = hash_function(symbol->getname());
        table[index_number].push_back(symbol);
        return true;
    }
bool delete_from_scope(symbol_info* symbol)
{
    string name = symbol->getname();
    int idx = hash_function(name);
    
    auto& bucket = table[idx];

    for (auto it = bucket.begin(); it != bucket.end(); ++it)
    {
        if ((*it)->getname() == name)
        {
            bucket.erase(it);
            return true;
        }
    }
    return false;
}

    void print_scope_table(ofstream& outlog)
{
    outlog << "ScopeTable # " << unique_id << endl;

    for(int i = 0; i < bucket_count; i++)
    {
        auto& bucket = table[i];

        if(bucket.empty())
            continue;

        outlog << i << " --> " << endl;

        for(symbol_info* sym : bucket)
        {
            outlog << "< " << sym->getname()
                   << " : " << sym->get_type()
                   << " >" << endl;

            string stype = sym->get_symbol_type();
            outlog << stype << endl;

            if(stype == "Function Definition")
            {
                auto params = sym->get_params();
                int sz = params.size();
                sym->set_size(sz);

                outlog << "Return Type: " << sym->get_return_type() << endl;
                outlog << "Number of Parameters: " << sz << endl;
                outlog << "Parameter Details: ";

                for(int j = 0; j < sz; j++)
                {
                    outlog << params[j];
                    if(j + 1 < sz) outlog << ", ";
                }
                outlog << endl;
            }
            else
            {
                outlog << "Type: " << sym->get_return_type() << endl;

                if(stype == "Array")
                    outlog << "Size: " << sym->get_size() << endl;
            }
        }

        outlog << endl;
    }
}

    ~scope_table()
    {
        for (int i = 0; i < bucket_count; ++i)
        {
            for (symbol_info *sym : table[i])
            {
                delete sym;
            }
        }
    }

    // you can add more methods if you need
};
 
// complete the methods of scope_table class
//void scope_table::print_scope_table(ofstream& outlog)
//{
//    outlog << "ScopeTable # "+ to_string(unique_id) << endl;

    //iterate through the current scope table and print the symbols and all relevant information
//}