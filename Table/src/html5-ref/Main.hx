import js.Browser;
import js.html.Element;

typedef Tag = {
    var name:String;
    var desc:String;
}

class Main {
    static var data:Array<Tag>;
    static var filtered:Array<Tag>;
    static var currentSortColumn:String = "";
    static var sortAscending:Bool = true;

    static function main() {
        var jsonString = haxe.Resource.getString("data.json");
        data = haxe.Json.parse(jsonString);
        filtered = data.copy();

        injectCSS();
        buildSearchBox();
        buildTable();
    }

    // -------------------------------------------------------------
    // 1. CSS Styling
    // -------------------------------------------------------------
    static function injectCSS() {
        var css = "
            table {
                border-collapse: collapse;
                margin: 20px;
                font-family: Arial, sans-serif;
                width: 600px;
            }
            th, td {
                padding: 10px;
                border: 1px solid #ccc;
                text-align: left;
            }
            th {
                background: #444;
                color: white;
                cursor: pointer;
                user-select: none;
            }
            tr:nth-child(even) {
                background: #f2f2f2;
            }
            tr:hover {
                background: #e0e0e0;
            }
            #searchBox {
                margin: 20px;
                padding: 8px;
                width: 300px;
                font-size: 16px;
            }
            .sort-icon {
                margin-left: 6px;
                font-size: 12px;
                opacity: 0.7;
            }
        ";

        var style = Browser.document.createElement("style");
        style.textContent = css;
        Browser.document.head.appendChild(style);
    }

    // -------------------------------------------------------------
    // 2. Search box for filtering
    // -------------------------------------------------------------
    static function buildSearchBox() {
var input:js.html.InputElement =
    cast Browser.document.createElement("input");

input.id = "searchBox";
input.placeholder = "Search by name";

input.oninput = function(_) {
    var q = input.value.toLowerCase();
    filtered = data.filter(p ->
        p.name.toLowerCase().indexOf(q) != -1
    );
    buildTable();
};

        Browser.document.body.appendChild(input);
    }

    // -------------------------------------------------------------
    // 3. Build the table (called after filtering or sorting)
    // -------------------------------------------------------------
    static function buildTable() {
        var doc = Browser.document;

        // Remove old table
        var old = doc.getElementById("tagTable");
        if (old != null) old.remove();

        var table = doc.createElement("table");
        table.id = "tagTable";

        // Header row
        var header = doc.createElement("tr");
        addHeader(header, "Name",  "name");
        addHeader(header, "Desc",   "desc");
        table.appendChild(header);

        // Data rows
        for (person in filtered) {
            var row = doc.createElement("tr");

            row.appendChild(cell(person.name));
            row.appendChild(cell(person.desc));

            table.appendChild(row);
        }

        doc.body.appendChild(table);
    }

    // -------------------------------------------------------------
    // 4. Helper: create a table cell
    // -------------------------------------------------------------
    static function cell(text:String):Element {
        var td = Browser.document.createElement("td");
        td.textContent = text;
        return td;
    }

    // -------------------------------------------------------------
    // 5. Sortable header with icons
    // -------------------------------------------------------------
    static function addHeader(row:Element, title:String, field:String) {
        var th = Browser.document.createElement("th");

        var label = Browser.document.createElement("span");
        label.textContent = title;

        var icon = Browser.document.createElement("span");
        icon.className = "sort-icon";

        // Show icon only on active column
        if (currentSortColumn == field) {
            icon.textContent = sortAscending ? "▲" : "▼";
        }

        th.appendChild(label);
        th.appendChild(icon);

        th.onclick = function(_) {
            if (currentSortColumn == field) {
                sortAscending = !sortAscending;
            } else {
                currentSortColumn = field;
                sortAscending = true;
            }

            filtered.sort(function(a, b) {
                var va = Reflect.field(a, field);
                var vb = Reflect.field(b, field);

                if (va < vb) return sortAscending ? -1 : 1;
                if (va > vb) return sortAscending ? 1 : -1;
                return 0;
            });

            buildTable();
        };

        row.appendChild(th);
    }
}