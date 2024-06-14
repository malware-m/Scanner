#!/bin/bash

echo "                -*-*-* Created By Team M@lware -*-*-*     "

read -p "Scan with Nmap or Naabu: " option

case "$option" in 
    nmap)
        echo "Scanning with Nmap..."
        
        read -p "Single Target or a file (single or file): " input_type

        if [ "$input_type" = "single" ]; then
            read -p "Enter the target IP/hostname: " target
        elif [ "$input_type" = "file" ]; then
            read -p "Enter the path of the file: " file
        else
            echo "Invalid input type. Please enter 'single' or 'file'."
            exit 1
        fi

        read -p "Choose scan type (normal or advance): " scan_type

        if [ "$scan_type" = "normal" ]; then
            ports_option=""
        elif [ "$scan_type" = "advance" ]; then
            read -p "Choose scan protocol (all or custom): " scan_protocol
            case "$scan_protocol" in
                all)
                    ports_option="-p-"
                    ;;
                custom)
                    read -p "Enter custom port types (tcp or udp): " custom_port_types
                    case "$custom_port_types" in
                        tcp)
                            read -p "Scan all TCP ports or specify custom ports? (all/custom): " tcp_option
                            if [ "$tcp_option" = "all" ]; then
                                ports_option="-p T:-"
                            elif [ "$tcp_option" = "custom" ]; then
                                read -p "Enter custom TCP ports (e.g., 80,443,8080): " custom_tcp_ports
                                ports_option="-p T:$custom_tcp_ports"
                            else
                                echo "Invalid option. Please enter 'all' or 'custom'."
                                exit 1
                            fi
                            ;;
                        udp)
                            read -p "Scan all UDP ports or specify custom ports? (all/custom): " udp_option
                            if [ "$udp_option" = "all" ]; then
                                ports_option="-p U:-"
                            elif [ "$udp_option" = "custom" ]; then
                                read -p "Enter custom UDP ports (e.g., 53,161): " custom_udp_ports
                                ports_option="-p U:$custom_udp_ports"
                            else
                                echo "Invalid option. Please enter 'all' or 'custom'."
                                exit 1
                            fi
                            ;;
                        
                        *)
                            echo "Invalid port type. Please choose 'tcp' or 'udp'."
                            exit 1
                            ;;
                    esac
                    ;;
                *)
                    echo "Invalid scan protocol. Please choose 'all' or 'custom'."
                    exit 1
                    ;;
            esac
            
            read -p "Specify scan timing template? (yes/no): " timing_scan
            if [ "$timing_scan" = "yes" ]; then
                read -p "Enter timing template (0-5): " timing_template
                if [[ "$timing_template" =~ ^[0-5]$ ]]; then
                    timing_option="-T$timing_template"
                else
                    echo "Invalid timing template. Please enter a number between 0 and 5."
                    exit 1
                fi
            else
                timing_option=""
            fi

            read -p "Apply Nmap scripting? (yes/no): " script_apply
            case "$script_apply" in
                yes)
                    read -p "Use default scripts or input custom script? (default/custom): " script_option_choice
                    if [ "$script_option_choice" = "default" ]; then
                        script_option="--script=default"
                    elif [ "$script_option_choice" = "custom" ]; then
                        read -p "Enter custom Nmap script: " custom_script
                        script_option="--script=$custom_script"
                    else
                        echo "Invalid option. Please enter 'default' or 'custom'."
                        exit 1
                    fi
                    ;;
                no)
                    script_option=""
                    ;;
                *)
                    echo "Invalid option. Please enter 'yes' or 'no'."
                    exit 1
                    ;;
            esac
        else
            echo "Invalid scan type. Please choose 'normal' or 'advanced'."
            exit 1
        fi

        case "$input_type" in
            single)
                if [ "$scan_type" = "normal" ]; then
                    sudo nmap -v $ports_option $target -oX nmap.xml
                elif [ "$scan_type" = "advance" ]; then
                    sudo nmap -v -sS -sV -A $ports_option $timing_option $script_option $target -oX nmap.xml
                else
                    echo "Invalid scan type. Please choose 'normal' or 'advanced'."
                    exit 1
                fi
                ;;
            file)
                if [ -f "$file" ]; then
                    if [ "$scan_type" = "normal" ]; then
                        sudo nmap -v $ports_option -iL $file -oX nmap.xml
                    elif [ "$scan_type" = "advance" ]; then
                       sudo nmap -v -sS -sV -A $ports_option $timing_option $script_option -iL $file -oX nmap.xml
                    else
                        echo "Invalid scan type. Please choose 'normal' or 'advanced'."
                        exit 1
                    fi
                else
                    echo "File not found: $file"
                    exit 1
                fi
                ;;
            *)
                echo "Invalid input type."
                exit 1
                ;;
        esac
        ;;

    naabu)
        echo "Scanning with Naabu..."
        
        read -p "Single Target or a file (single or file): " input_type

        if [ "$input_type" = "single" ]; then
            read -p "Enter the target IP/hostname: " target
        elif [ "$input_type" = "file" ]; then
            read -p "Enter the path of the file: " file
        else
            echo "Invalid input type. Please enter 'single' or 'file'."
            exit 1
        fi
        
        
         read -p "Scan all ports or specify specific ports? (all/specific): " port_option
    case "$port_option" in
        all)
            ports_option=""
            ;;
        specific)
            read -p "Enter specific ports (e.g., 80,443,8080): " specific_ports
            ports_option="-p $specific_ports"
            ;;
        *)
            echo "Invalid option. Please enter 'all' or 'specific'."
            exit 1
            ;;
    esac
          
        case "$input_type" in
           single)
                sudo naabu $ports_option -host $target -o naabu.txt
                ;;
            file)
                if [ -f "$file" ]; then
                    sudo naabu $ports_option -list $file -o naabu.txt
                else
                    echo "File not found: $file"
                    exit 1
                fi
                ;;
            *)
                echo "Invalid input type."
                exit 1
                ;;
        esac
        ;;

    *)
        echo "Invalid option."
        exit 1
        ;;
esac


if [ "$option" = "nmap" ]; then
    echo "----------------------------"
    echo "Converting .xml format to .html"
    xsltproc nmap.xml -o nmap.html
fi
