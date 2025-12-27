#include "scope_table.h"
#include <fstream>
//lab3 starts
class SymbolTable
{
private:
    scope_table *current_scope;
    int bucket_count;
    int current_scope_id;
    std::ofstream *outlog;

public:
    SymbolTable(int bucket_count, std::ofstream* outlog){
        this->bucket_count = bucket_count;
        this->current_scope_id = 0;
        current_scope = nullptr;
        this->outlog = outlog;
    }
    ~SymbolTable(){
        while(current_scope != nullptr){
            exit_scope();
        }
    }
    void enter_scope(){
        // create new scope with a new unique id
        current_scope_id++;
        scope_table* new_scope = new scope_table(bucket_count, current_scope_id, current_scope);
        current_scope = new_scope;
        if(outlog) (*outlog) << "New ScopeTable with ID " << current_scope_id << " created" << std::endl << std::endl;
    }
    void exit_scope(){
        if(current_scope == nullptr){
            if(outlog) (*outlog) << "No ScopeTable to remove" << std::endl << std::endl;
            return;
        }
        if(outlog) (*outlog) << "Scopetable with ID " << current_scope->get_unique_id() << " removed" << std::endl << std::endl;
        scope_table* temp = current_scope;
        current_scope = current_scope->get_parent_scope();
        delete temp;

    }
    bool insert(symbol_info* symbol){
        if(current_scope == nullptr){
            return false;
        }
        return current_scope->insert_in_scope(symbol);
    }
    symbol_info* lookup(symbol_info* symbol){
        string name = symbol->getname();
        scope_table* temp = current_scope;
        while(temp != nullptr){
            symbol_info* found_symbol = temp->lookup_in_scope(symbol);
            if(found_symbol != nullptr){
                return found_symbol;
            }
            temp = temp->get_parent_scope();
        }
        return nullptr;    
    }
    void print_current_scope(){
        if(current_scope != nullptr){
            if(outlog) current_scope->print_scope_table(*outlog);
        }
        else{
            if(outlog) (*outlog) << "No active scope table" << std::endl << std::endl;
        }
    }
    void print_all_scopes(){
        if(outlog) (*outlog) << "################################" << std::endl << std::endl;
        scope_table *temp = current_scope;
        while (temp != nullptr)
        {
            if(outlog) temp->print_scope_table(*outlog);
            temp = temp->get_parent_scope();
        }
        if(outlog) (*outlog) << "################################" << std::endl << std::endl;  
    }
bool exists_in_current_scope(string name)
    {
        if (current_scope != NULL)
        {
            return current_scope->exists_in_current_scope(name);
        }
        return false;
    };
    // you can add more methods if you need 
};
