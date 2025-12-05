#include "scope_table.h"

class symbol_table
{
private:
    scope_table *current_scope;
    int bucket_count;
    int current_scope_id;

public:
    symbol_table(int bucket_count,ofstream* outlog){
        this->bucket_count = bucket_count;
        this->current_scope_id = 1;
        current_scope = NULL;
        this.outlog = outlog;
    }
    ~symbol_table(){
        while(current_scope != NULL){
            exit_scope();
        }
    }
    void enter_scope(){
        scope_table* new_scope = new scope_table(bucket_count, current_scope_id, current_scope);
        current_scope = new_scope;
        *outlog << "New ScopeTable with ID " + to_string(current_scope_id) + " created" << endl << endl;
    }
    void exit_scope(){
        if(current_scope == NULL){
            *outlog << "No ScopeTable to remove" << endl << endl;
            return;
        }
        *outlog << "ScopeTable with ID " + to_string(current_scope_id) + " removed" << endl << endl;
        scope_table* temp = current_scope;
        current_scope = current_scope->get_parent_scope();
        delete temp;

    }
    bool insert(symbol_info* symbol){
        if(current_scope == NULL){
            //*outlog << "No ScopeTable exists. Cannot insert symbol." << endl << endl;
            return false;
        }
        return current_scope->insert_in_scope(symbol);
    }
    symbol_info* lookup(symbol_info* symbol){
        string name = symbol->get_name();
        scope_table* temp = current_scope;
        while(temp != NULL){
            symbol_info* found_symbol = temp->lookup_in_scope(symbol);
            if(found_symbol != NULL){
                return found_symbol;
            }
            temp = temp->get_parent_scope();
        }
        return NULL;    
    }
    void print_current_scope(){
        if(current_scope == NULL){
            current_scope->print_scope_table(*outlog);
    }
        else{
            *outlog << "No active scope table" << endl << endl;
        }
    void print_all_scopes(ofstream& outlog){
        outlog<<"################################"<<endl<<endl;
        scope_table *temp = current_scope;
        while (temp != NULL)
        {
            temp->print_scope_table(outlog);
            temp = temp->get_parent_scope();
        }
        outlog<<"################################"<<endl<<endl;  
    }

    // you can add more methods if you need 
};

// complete the methods of symbol_table class


// void symbol_table::print_all_scopes(ofstream& outlog)
// {
//     outlog<<"################################"<<endl<<endl;
//     scope_table *temp = current_scope;
//     while (temp != NULL)
//     {
//         temp->print_scope_table(outlog);
//         temp = temp->get_parent_scope();
//     }
//     outlog<<"################################"<<endl<<endl;
// }