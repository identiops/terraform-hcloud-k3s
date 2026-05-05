Renamed the shared k3s default local to `k3s_control_plane_config_default` and propagated the new name through module inputs and the child module variable.

Terraform formatting needed to be reapplied after the rename because HCL alignment changed in the module blocks.
